# 👻 GhostLLM: Self-Hosted AI Mesh with Ollama + LiteLLM + OpenWebUI

[![Arch-Based](https://img.shields.io/badge/Arch%20Linux-optimized-blue?logo=arch-linux\&logoColor=white)](https://archlinux.org)
[![LLM Powered](https://img.shields.io/badge/Ollama-33B-inference-success?logo=openai\&logoColor=white)](https://ollama.com)
[![VSCode Integrated](https://img.shields.io/badge/VSCode-Continue-blueviolet?logo=visualstudiocode\&logoColor=white)](https://marketplace.visualstudio.com/items?itemName=Continue.continue)
[![LiteLLM API](https://img.shields.io/badge/LiteLLM-Staging-yellow?logo=fastapi\&logoColor=white)](https://github.com/BerriAI/litellm)
[![Federated Nodes](https://img.shields.io/badge/GPU%20Pool-4090%2F3070%2F2060-green?logo=nvidia\&logoColor=white)](https://ollama.com)
[![NVIDIA Enabled](https://img.shields.io/badge/NVIDIA-Accelerated-success?logo=nvidia\&logoColor=white)](https://www.nvidia.com/)

> Self-hosted, federated AI mesh using Ollama + LiteLLM + OpenWebUI. Powered by Arch, Proxmox, and RTX-class GPUs.

---

## 📆 System Overview

| Component           | Hostname     | Role                              | GPU      |
| ------------------- | ------------ | --------------------------------- | -------- |
| Arch Daily Driver   | `ck-arch`    | Primary Ollama + LiteLLM Gateway  | RTX 4090 |
| Workstation (Win11) | `reso-dt-01` | Remote Ollama (WSL2 planned)      | RTX 3070 |
| Proxmox Node        | `pve-host1`  | OpenWebUI + LiteLLM LXC Instances | RTX 2060 |

---

## 📦 Components

### 🧠 LLMs via Ollama (Arch Workstation)

* `deepseek-coder:33b` — for high-performance code completion
* `deepseek-r1:32b` — general-purpose model
* `llama3:8b` — fallback, interactive local model
* `dolphin-mixtral` — exploratory / multimodal support

> All models are accelerated via RTX 4090. Other nodes (3070/2060) can register their Ollama endpoints in future.

---

### 👤 OpenWebUI (Proxmox LXC)

* Lightweight LXC on `pve-host1`
* Reverse-proxied via NGINX
* Internal chat frontend for any Ollama backend (including LiteLLM)

---

### 🛩️ VSCode Integration (Continue)

* [Continue Extension](https://marketplace.visualstudio.com/items?itemName=Continue.continue)
* Default model set to `deepseek-coder:33b`
* Config lives in `ghostllm/vscode/config.yaml`

---

### 🦜 LiteLLM (API Gateway)

* LXC container hosted on `pve-host1`
* Provides unified OpenAI-compatible API at [`https://ai.cktechx.io`](https://ai.cktechx.io)
* Supports:

  * Centralized routing to multiple Ollama backends
  * API key auth with `sk-*` tokens
  * Native support for Azure/OpenAI/Gemini API fallback
* Access logs and usage routed via NGINX and `.env`

---

## 📁 Repo Structure

```bash
ghostllm/
├── vscode/         # Continue config (VSCode)
├── ollama/         # Pull scripts, model info
├── open-webui/     # Setup + reverse proxy
├── nginx/          # Public proxy configs (SSL)
├── litellm_config.yaml
├── .env            # API keys and salt
├── run.sh          # Local startup wrapper
```

---

## ⚙️ Platform

* **Primary Host**: Arch Linux (CK-arch, RTX 4090)
* **Work Remote**: Win11 (reso-dt-01, RTX 3070 WSL2 planned)
* **Proxmox LXC Host**: pve-host1 (5900X / RTX 2060)

---

## 🧠 Future Plans

* Add vector DB for RAG (Weaviate, Chroma, or Qdrant)
* Expand `ghostctl` to register remote nodes and do health checks
* Integrate LiteLLM auth + usage logging via Loki/Grafana
* Merge into `PhantomBoot` as part of recovery+model bootstrap
* Auto-route models by availability/load (4090/3070/2060 fallback)

---
