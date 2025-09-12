# VM Networking Setup

## Current VM Configuration

### VMs in Use
- **ghostnv-arch**: Arch development VM 
- **Win11**: Windows 11 work VM
- **fedora**: Fedora VM (planned)

### Network Infrastructure

#### Bridge Networking (br0)
- **Interface**: br0 (10.0.0.21/24)
- **Physical Interface**: eno1 (bridged)
- **Purpose**: Provides VMs with direct network access
- **DHCP**: VMs get IPs from main router/DHCP server

#### VM Network Interfaces
- VMs connect via tap interfaces (e.g., vnet0)
- Tap interfaces are bridged to br0
- VMs appear as separate devices on the network

### Network Services

#### Tailscale
- **Interface**: tailscale0 (100.88.3.33/32)
- **Purpose**: VPN/mesh networking
- **Access**: Secure remote access to VMs and host

#### Docker Networking
- **docker0**: 172.17.0.1/16 (default bridge)
- **Custom bridges**: br-8237cbe3b15d, br-70ce41f8c8f0
- **Containers**: GhostHub, Redis, Ollama, etc.

## Network Configuration Commands

### Bridge Management
```bash
# Show bridge configuration
brctl show

# Check bridge interfaces
ip addr show br0
```

### VM Networking Troubleshooting
```bash
# If VMs lose network connectivity, disable bridge netfilter
echo 0 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

# Restart libvirt networking
systemctl restart libvirtd

# Check VM network interfaces
virsh domiflist <vm-name>
```

### Libvirt Network Management
```bash
# List virtual networks
virsh net-list --all

# Start/stop networks
virsh net-start <network>
virsh net-destroy <network>
```

## Network Topology

```
Internet
    │
Router/DHCP (10.0.0.1)
    │
┌───┴────────────────────────────┐
│ Physical Host (10.0.0.21)      │
│  ├─ br0 (bridge)               │
│  ├─ tailscale0 (VPN)           │
│  └─ Docker bridges             │
│                                │
│  VMs (bridged to br0):         │
│  ├─ ghostnv-arch               │
│  ├─ Win11                      │
│  └─ fedora (planned)           │
└────────────────────────────────┘
```

## Common Issues

### VM Network Loss
- **Cause**: Docker/container changes can affect bridge netfilter
- **Fix**: Disable bridge netfilter: `echo 0 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables`

### DHCP Not Working
- **Check**: Ensure br0 is properly bridged to physical interface
- **Verify**: Physical interface (eno1) should not have IP, only br0 should

### Performance
- **Virtio**: Use virtio-net drivers in VMs for better performance
- **Bridge**: Bridge networking provides better performance than NAT