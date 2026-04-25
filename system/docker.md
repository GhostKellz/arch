# docker.md

Docker configuration and kernel requirements.

---

## Kernel Requirements

Docker networking requires specific kernel modules. These are configured in the kernel myfrag files.

### Netfilter / nftables

```
CONFIG_NETFILTER=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_TABLES=y
CONFIG_NFT_NAT=m
CONFIG_NFT_MASQ=m
CONFIG_NFT_COMPAT=m              # nftables compat layer for iptables-nft
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_NAT=m
CONFIG_IP_NF_TARGET_MASQUERADE=m
```

### Bridge / EBTABLES

```
CONFIG_BRIDGE=m
CONFIG_BRIDGE_NETFILTER=m
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_NF_EBTABLES_LEGACY=m
CONFIG_NF_CONNTRACK_BRIDGE=m
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m
```

### Container Networking

```
CONFIG_TUN=m
CONFIG_VETH=m
CONFIG_MACVLAN=m
CONFIG_IPVLAN=m
CONFIG_VXLAN=m
```

### Cgroups

```
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CGROUP_BPF=y
CONFIG_MEMCG=y
CONFIG_BLK_CGROUP=y
CONFIG_CGROUP_PIDS=y
```

---

## GPU Support (NVIDIA)

For Ollama and other GPU workloads:

1. Install nvidia-container-toolkit:
   ```bash
   yay -S nvidia-container-toolkit
   ```

2. Configure Docker daemon:
   ```json
   # /etc/docker/daemon.json
   {
     "runtimes": {
       "nvidia": {
         "path": "nvidia-container-runtime",
         "runtimeArgs": []
       }
     }
   }
   ```

3. Restart Docker:
   ```bash
   sudo systemctl restart docker
   ```

4. Test:
   ```bash
   docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
   ```

---

## IP Virtual Server (Swarm/Load Balancing)

For Docker Swarm or load balancing:

```
CONFIG_IP_VS=m
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_NFCT=y
CONFIG_NETFILTER_XT_MATCH_IPVS=m
```

---

## Troubleshooting

### DNS Resolution Failures

If containers can't resolve DNS, check:
1. Kernel has bridge and netfilter modules loaded
2. nftables rules aren't blocking DNS (port 53)
3. Docker's embedded DNS is running

```bash
# Check loaded modules
lsmod | grep -E 'br_netfilter|nf_conntrack|xt_'

# Check Docker DNS
docker run --rm alpine nslookup google.com
```

### CONNMARK Errors (Tailscale)

If running Tailscale with Docker, kernel needs CONNMARK modules:

```
CONFIG_NETFILTER_XT_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NET_ACT_CONNMARK=m
```

These are included in the ghostkellz.myfrag kernel configs.
