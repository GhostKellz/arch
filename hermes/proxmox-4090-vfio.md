# Proxmox + RTX 4090 (VFIO Passthrough) — Hermes Deployment

Our plan for leveraging the **RTX 4090** in the Proxmox lab (PVE 3 — 14900K /
128GB DDR5 / RTX 4090) to serve a **local model endpoint** that Hermes points at.
The 4090 is passed into a guest VM via **VFIO passthrough**; that VM runs an
OpenAI-compatible inference server (Ollama or vLLM); Hermes (on the workstation,
the VM itself, or an always-on gateway node) targets that endpoint.

> Fill in the bracketed `<…>` specifics for our actual host — this documents the
> shape of the deployment, not guessed IDs.

## Architecture

```
┌─────────────────────────┐        OpenAI-compatible HTTP        ┌──────────────────────┐
│ Hermes client           │  ───────────────────────────────▶   │ PVE 3 guest VM       │
│ (Arch workstation / TUI │   http://<vm-lan-ip>:<port>/v1       │ RTX 4090 via VFIO    │
│  / Telegram gateway)    │                                     │ Ollama or vLLM server│
└─────────────────────────┘                                     └──────────────────────┘
```

Keep the model endpoint on the LAN; don't expose it publicly without auth + a proxy.

## Part 1 — VFIO passthrough on the Proxmox host

Reference checklist (confirm against the current Proxmox wiki for your kernel):

1. **Enable IOMMU** in firmware (VT-d for the 14900K) and in the bootloader.
   - GRUB: add `intel_iommu=on iommu=pt` to `GRUB_CMDLINE_LINUX_DEFAULT`, then
     `update-grub`. (systemd-boot: edit `/etc/kernel/cmdline`, `proxmox-boot-tool refresh`.)
2. **Load vfio modules** in `/etc/modules`:
   ```
   vfio
   vfio_iommu_type1
   vfio_pci
   ```
3. **Find the GPU + its audio function** and IOMMU group:
   ```
   lspci -nnk | grep -A3 NVIDIA      # note PCI addrs + [vendor:device] IDs
   ```
   The 4090 is typically `<bus>:00.0` (VGA) + `<bus>:00.1` (HDMI audio) — pass
   **both** functions, and confirm they're in a clean IOMMU group.
4. **Bind to vfio-pci** so the host driver doesn't grab the card:
   ```
   echo "options vfio-pci ids=<vendor:device>,<audio vendor:device>" > /etc/modprobe.d/vfio.conf
   echo -e "blacklist nouveau\nblacklist nvidia\nblacklist nvidiafb" > /etc/modprobe.d/blacklist-nvidia.conf
   update-initramfs -u -k all      # then reboot
   ```
5. **Verify** after reboot:
   ```
   dmesg | grep -i vfio
   lspci -nnk -d <vendor:device>   # "Kernel driver in use: vfio-pci"
   ```

## Part 2 — Attach the GPU to the guest VM

In the VM's Proxmox config (`Hardware → Add → PCI Device`, or `/etc/pve/qemu-server/<vmid>.conf`):

- Add `hostpci0: <bus>:00,pcie=1` (the comma-less form passes the whole function
  group; use `x-vga=1` only if you also want guest console output on the card).
- Set the VM **Machine** type to `q35` and **BIOS** to `OVMF (UEFI)`.
- CPU type `host`; give it generous RAM (the host has 128GB) and pinned vCPUs.
- Modern NVIDIA cards usually **don't** need the old `kvm=off` / vendor-id hack,
  but keep it in mind if the driver throws Code 43.

## Part 3 — Inside the guest: model server

Install the NVIDIA driver + CUDA in the guest, confirm `nvidia-smi` sees the 4090,
then run one of:

### Option A — Ollama (simplest)

```bash
curl -fsSL https://ollama.com/install.sh | sh
# pull a strong tool-calling model; mind Hermes's 64k context floor
ollama pull qwen2.5-coder:32b
# serve on the LAN (default 11434); set context via the model/Modelfile or num_ctx
OLLAMA_HOST=0.0.0.0:11434 ollama serve
```
OpenAI-compatible endpoint: `http://<vm-lan-ip>:11434/v1`

### Option B — vLLM (higher throughput, OpenAI server)

```bash
pip install vllm
python -m vllm.entrypoints.openai.api_server \
  --model <hf-model-id> \
  --host 0.0.0.0 --port 8000 \
  --max-model-len 65536            # >= 64k context — required by Hermes
```
Endpoint: `http://<vm-lan-ip>:8000/v1`

> **Hard requirement:** the served model must expose **≥ 64,000 tokens** of
> context or Hermes won't run reliably. With Ollama set `num_ctx` accordingly; the
> 4090's 24GB VRAM bounds how large a model + context you can fit.

## Part 4 — Point Hermes at it

On whichever box runs Hermes:

```bash
hermes model      # choose the local / OpenAI-compatible option
                  # base URL: http://<vm-lan-ip>:<port>/v1
                  # model:    qwen2.5-coder:32b  (or your vLLM model id)
                  # api key:  any placeholder if the server doesn't require one
```

Because memory + skills live in `~/.hermes/` (not tied to the model), you can flip
between this local 4090 endpoint and a frontier API with `hermes model` without
losing learned context.

## Where Hermes itself runs

Three viable layouts:

1. **Client on workstation, model on PVE 3** — daily driver; workstation `hermes`
   targets the 4090 endpoint over LAN.
2. **Hermes on the VM** — co-locate agent + model on PVE 3; lowest latency.
3. **Gateway on an always-on node** (PVE 7) targeting the PVE 3 endpoint — best for
   cron/Telegram automation that must fire even when the workstation is off.

## Verify end-to-end

```bash
# from the Hermes host, confirm the endpoint answers:
curl http://<vm-lan-ip>:<port>/v1/models
hermes chat -q "Hello — confirm you're running on the local 4090 endpoint."
hermes doctor
```

## Gotchas

- **Code 43 / driver fails in guest** — revisit q35+OVMF, ensure both GPU functions
  passed, try the `kvm=off`/vendor-id hack only if needed.
- **Host steals the GPU** — the vfio-pci bind + nouveau/nvidia blacklist on the
  *host* is what prevents this; re-check `Kernel driver in use`.
- **Endpoint unreachable** — bind the server to `0.0.0.0` (not `127.0.0.1`) and
  open the guest firewall; keep it LAN-only.
- **VRAM limits** — 24GB caps model size at the chosen context length; quantize or
  drop context (but not below 64k) if you OOM.
