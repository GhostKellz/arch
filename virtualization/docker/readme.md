# 🐳 virtualization/docker/

[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/) [![GhostKellz](https://img.shields.io/badge/GhostKellz-👻-blueviolet)](https://github.com/ghostkellz) [![GPU-Accelerated](https://img.shields.io/badge/GPU-Accelerated-00bcd4)](https://developer.nvidia.com/gpu-accelerated-applications)

---

> 🛠️ **About this folder:**  
> This directory contains GPU-accelerated container services running on top of Arch Linux + Proxmox, leveraging NVIDIA RTX GPUs for AI/LLM workloads.

Built for:
- Arch Linux + Proxmox (bare metal + passthrough)
- LXC, KVM, direct GPU compute containers
- Ollama, OpenWebUI, LiteLLM, and future model hosting
- SDWAN-enabled environment for hybrid cloud/home lab flexibility

---

## 📂 Current Contents

```
virtualization/docker/
├── README.md
├── ollama/              # RTX4090 Ollama standalone + multi-GPU
├── openwebui/           # Web-based Ollama/LLM interface (via LXC container)
├── litellm/             # LiteLLM API router for OpenAI, Azure, Gemini, local models
└── models/              # Model management notes: DeepSeek, Llama3, Mistral, etc.
```

### 🔥 Active Projects
- **Ollama** - Local LLM server with GPU acceleration (RTX 4090, 3070, 2060)
- **OpenWebUI** - Frontend interface for Ollama models and API tools
- **LiteLLM** - Smart routing across OpenAI, Azure Copilot, Google Gemini, and local Ollama models

> More Docker Compose stacks and services can also be found in the [GhostKellz Docker repository](https://github.com/ghostkellz/docker)!

---

## 🎯 Key Architecture Notes

- **Multiple GPUs:** RTX 4090 (workstation), 3070 (secondary), 2060 (Proxmox server GPU passthrough)
- **LXC/NVIDIA integration:** OpenWebUI runs inside an LXC container mapped to Ollama
- **Model set:** DeepSeek Coder 6.7B/33B, DeepSeek R32, Llama3, Mistral 7B
- **Performance:** Optimized for NVENC/NVDEC acceleration and low-latency serving

---

## 📜 Future Expansion

- HuggingFace endpoint mirroring
- Custom Ollama model training pipelines
- LLM "hub" portal frontend (GhostCMS or Bricks Builder)
- Private OpenAI API fallback proxies
- CK Technology Open Model Registry (long term)

---

> **Maintained by:** [GhostKellz](https://github.com/ghostkellz)  
> **Powered by:** 🐳 Docker, 🖥️ Arch Linux, 🚀 RTX GPUs, 👻 Ghost Stack

---

Want to dive deeper into my self-hosted Docker stacks? Check out [ghostkellz/docker](https://github.com/ghostkellz/docker) for more! 👻


