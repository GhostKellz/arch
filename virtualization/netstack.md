# 🌐 CKTech Complete Network Stack

## Network Architecture Overview

### Physical Infrastructure
- **Host**: Arch Linux workstation (10.0.0.21/24)
- **WAN**: Fiber + Cable SD-WAN failover
- **Firewall**: Fortigate 90G securing WAN/LAN edges
- **Bridge**: br0 (bridges eno1 for VM networking)

### DNS Resolution Stack
- **Primary**: Unbound recursive resolver (local)
- **Upstream**: Apollo DoT server + Cloudflare fallback
- **Features**: DNSSEC validation, QNAME minimization, root hints auto-refresh
- **Config**: `/home/chris/arch/networking/unbound/`

## Virtualization Network Topology

```
Internet ← Fortigate 90G ← Router/DHCP (10.0.0.1)
                            │
    ┌───────────────────────┴─────────────────────────┐
    │ Arch Host (10.0.0.21)                           │
    │  ┌─ Physical: eno1 (bridged)                     │
    │  ├─ Bridge: br0 (10.0.0.21/24)                  │
    │  ├─ Tailscale: tailscale0 (100.88.3.33/32)     │
    │  ├─ Docker: docker0 (172.17.0.1/16)             │
    │  └─ DNS: Unbound (127.0.0.1:53)                 │
    │                                                  │
    │  Virtual Machines (via br0):                     │
    │  ┌─ ghostnv-arch (Arch dev VM)                   │
    │  ├─ Win11 (Windows work VM)                     │
    │  └─ fedora (planned)                            │
    │                                                  │
    │  Docker Containers:                              │
    │  ┌─ GhostHub (web app)                          │
    │  ├─ Redis (caching)                             │
    │  ├─ Ollama (LLM server)                         │
    │  └─ Custom bridges: br-*                       │
    └──────────────────────────────────────────────────┘
```

## Network Services

### 1. Bridge Networking (br0)
- **Purpose**: Direct VM network access
- **Interface**: br0 bridges eno1
- **DHCP**: VMs get IPs from main router
- **VM Interfaces**: vnet0, vnet1, etc. (tap interfaces)

### 2. Tailscale Mesh VPN
- **Interface**: tailscale0 (100.88.3.33/32)
- **Purpose**: Zero-trust mesh networking
- **Backend**: Self-hosted Headscale server
- **Features**: WireGuard-based, global mesh, secure remote access

### 3. DNS Resolution (Unbound)
- **Bind**: 127.0.0.1:53
- **Type**: Recursive resolver with DNSSEC
- **Upstreams**: 
  - Primary: Apollo DoT server
  - Fallback: Cloudflare (1.1.1.1)
- **Security**: QNAME minimization, hardened config
- **Maintenance**: Auto root hints refresh via systemd timer

### 4. Docker Networking
- **Default**: docker0 (172.17.0.1/16)
- **Custom**: br-8237cbe3b15d, br-70ce41f8c8f0
- **Containers**: GhostHub, Redis, Ollama, development containers

## VM Configurations

### ghostnv-arch (Development VM)
- **OS**: Arch Linux
- **Purpose**: Development environment
- **Network**: Bridge (br0) - gets DHCP IP
- **Access**: Direct network + Tailscale mesh

### Win11 (Work VM)
- **OS**: Windows 11
- **Purpose**: Work applications
- **Network**: Bridge (br0) - gets DHCP IP  
- **Drivers**: e1000e network adapter

### fedora (Planned)
- **OS**: Fedora
- **Purpose**: Testing/development
- **Network**: Bridge (br0) planned

## Network Management Commands

### Bridge Networking
```bash
# Check bridge status
brctl show
ip addr show br0

# Fix VM network connectivity issues
echo 0 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables
systemctl restart libvirtd
```

### DNS Management
```bash
# Check Unbound status
systemctl status unbound

# Test DNS resolution
dig @127.0.0.1 example.com
nslookup example.com 127.0.0.1

# Reload Unbound config
systemctl reload unbound
```

### Tailscale Management
```bash
# Check Tailscale status
tailscale status

# Connect to mesh
tailscale up

# Check routes
tailscale route list
```

### VM Network Debugging
```bash
# List VM network interfaces
virsh domiflist <vm-name>

# Check VM network stats
virsh domifstat <vm-name> <interface>

# List all VMs
virsh list --all
```

## Security Features

### Network Isolation
- **Firewall**: Fortigate 90G edge protection
- **DNS**: Local Unbound prevents DNS leaks
- **VPN**: Tailscale mesh for secure remote access
- **Containers**: Isolated Docker networks

### DNS Security
- **DNSSEC**: Full validation enabled
- **Privacy**: No upstream logging (Apollo + local resolver)
- **Hardening**: QNAME minimization, aggressive security options
- **Redundancy**: Multiple upstream resolvers

### VM Security
- **Bridge**: VMs isolated but can access LAN
- **Tailscale**: Mesh access without exposing to internet
- **Updates**: Automated via VM-specific configs

## Troubleshooting

### Common Issues

#### VM Network Loss
```bash
# Disable bridge netfilter (common Docker conflict)
echo 0 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

# Restart networking
systemctl restart libvirtd
systemctl restart NetworkManager  # if needed
```

#### DNS Resolution Issues
```bash
# Check Unbound logs
journalctl -u unbound -f

# Test different resolvers
dig @127.0.0.1 example.com
dig @1.1.1.1 example.com
```

#### Tailscale Connectivity
```bash
# Check Tailscale status
tailscale status --self=false

# Restart Tailscale
systemctl restart tailscaled
tailscale up
```

## Performance Optimization

### VM Networking
- **Virtio**: Use virtio-net drivers for best performance
- **Bridge**: Bridge networking > NAT for performance
- **CPU**: Pin network interrupts to specific cores

### DNS Optimization
- **Cache**: Large cache size in Unbound config
- **Prefetch**: Key expiry prefetching enabled
- **Threads**: Multi-threaded resolution

### Container Networking
- **Host**: Use host networking for performance-critical containers
- **Bridge**: Custom bridges for service isolation
- **Resource**: CPU/memory limits on network-heavy containers

---

> 🔥 **CKTech Network Stack: Secure, Fast, Resilient**  
> 👻 Bridge-based virtualization with mesh VPN overlay and hardened DNS