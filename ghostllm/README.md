# 🧠 ghostllm

[![Arch-Based](https://img.shields.io/badge/Arch%20Linux-optimized-blue?logo=arch-linux\&logoColor=white)](https://archlinux.org)
[![LLM Powered](https://img.shields.io/badge/Ollama-33B-inference-success?logo=openai\&logoColor=white)](https://ollama.com)
[![VSCode Integrated](https://img.shields.io/badge/VSCode-Continue-blueviolet?logo=visualstudiocode\&logoColor=white)](https://marketplace.visualstudio.com/items?itemName=Continue.continue)
[![LiteLLM API](https://img.shields.io/badge/LiteLLM-Staging-yellow?logo=fastapi\&logoColor=white)](https://github.com/BerriAI/litellm)

> Self-hosted AI tooling and model integration on Arch Linux and Proxmox.

---

## 📦 Components

### 🧠 LLMs via Ollama (Arch Workstation)

* `deepseek-coder:33b` – for high-performance code completion
* `deepseek-r1:32b` – general-purpose model
* `llama3:8b` – fast fallback / light interaction

All models are pulled locally via [Ollama](https://ollama.com), with GPU acceleration (RTX 4090) for full-speed inference.

---

### 👤 OpenWebUI (Proxmox LXC)

* Hosted remotely in a lightweight LXC container
* Reverse-proxied and accessible over internal VPN
* Primary chat/interaction UI when not using the terminal

---

### 🧹 VSCode Integration

* [Continue Extension](https://marketplace.visualstudio.com/items?itemName=Continue.continue)
* Fully wired to use `deepseek-coder:33b` as the default model
* Config file managed under `ghostllm/vscode/config.yaml`

---

### 🧪 LiteLLM (Staging)

* A dedicated LXC is being staged for **LiteLLM** to provide:

  * Unified OpenAI-compatible API
  * Per-user limits, API keys, proxy routing
  * Integration target for scripts, clients, and dev tools

---

## 📁 Repo Structure

```bash
ghostllm/
├── vscode/         # Continue config for VSCode
├── ollama/         # Ollama model notes, pull scripts
├── open-webui/     # OpenWebUI setup & reverse proxy
├── nginx/          # (optional) proxy configs
```

---

## ⚙️ Platform

* **Host**: Arch Linux (Workstation)
* **Server**: Proxmox (OpenWebUI + LiteLLM LXCs)
* **GPU**: NVIDIA RTX 4090 (CUDA enabled for Ollama)

---

## 🧠 Future Plans

* Add Weaviate or Qdrant for embeddings
* Automate model selection via `ghostctl`
* Integrate ghostllm into PhantomBoot + GhostMesh stack

---

