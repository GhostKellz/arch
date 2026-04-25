# config-spec.md

Kernel CONFIG_* options specification for ghostkellz.myfrag.

Target: AMD Ryzen 9950X3D (Zen 5) / 64GB DDR5 / RTX 5090 / NVMe

---

## Containers & Namespaces

Required for Docker, Podman, LXC.

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_NAMESPACES` | y | Enable namespace support |
| `CONFIG_UTS_NS` | y | Hostname/domainname isolation |
| `CONFIG_PID_NS` | y | Process ID isolation |
| `CONFIG_NET_NS` | y | Network namespace isolation |
| `CONFIG_USER_NS` | y | User namespace (rootless containers) |
| `CONFIG_CGROUPS` | y | Control groups for resource limits |
| `CONFIG_MEMCG` | y | Memory cgroup controller |
| `CONFIG_MEMCG_SWAP` | y | Swap accounting in memory cgroup |
| `CONFIG_BLK_CGROUP` | y | Block I/O cgroup controller |
| `CONFIG_CGROUP_PIDS` | y | PID limit per cgroup |
| `CONFIG_CGROUP_FREEZER` | y | Freeze/thaw cgroups |
| `CONFIG_CGROUP_DEVICE` | y | Device access control (GPU passthrough) |
| `CONFIG_CGROUP_CPUACCT` | y | CPU accounting |
| `CONFIG_CGROUP_PERF` | y | Perf events per cgroup |
| `CONFIG_CGROUP_SCHED` | y | CPU scheduler cgroup |
| `CONFIG_CGROUP_BPF` | y | BPF programs per cgroup (nvidia-container-toolkit) |
| `CONFIG_NET_CLS_CGROUP` | m | Network classifier cgroup |
| `CONFIG_OVERLAY_FS` | m | OverlayFS for container layers |
| `CONFIG_SECCOMP` | y | Secure computing mode |
| `CONFIG_SECCOMP_FILTER` | y | Seccomp BPF filters |
| `CONFIG_SECURITY_APPARMOR` | y | AppArmor LSM (Docker default) |

---

## Netfilter / nftables

Required for Docker networking, firewalls, NAT.

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_NETFILTER` | y | Core netfilter framework |
| `CONFIG_NETFILTER_ADVANCED` | y | Advanced netfilter options |
| `CONFIG_NF_CONNTRACK` | y | Connection tracking |
| `CONFIG_NF_CONNTRACK_MARK` | y | Mark connections for routing |
| `CONFIG_NF_TABLES` | y | nftables core |
| `CONFIG_NF_TABLES_INET` | y | nftables inet family (IPv4+IPv6) |
| `CONFIG_NF_TABLES_IPV4` | y | nftables IPv4 |
| `CONFIG_NF_TABLES_IPV6` | y | nftables IPv6 |
| `CONFIG_NF_NAT` | y | NAT core |
| `CONFIG_NFT_NAT` | m | nftables NAT |
| `CONFIG_NFT_CHAIN_NAT` | m | NAT chain type |
| `CONFIG_NFT_CT` | m | Conntrack integration |
| `CONFIG_NFT_MASQ` | m | Masquerade (SNAT) |
| `CONFIG_NFT_REDIR` | m | Redirect (DNAT) |
| `CONFIG_NFT_FIB` | m | FIB lookups |
| `CONFIG_NFT_FIB_IPV4` | m | IPv4 FIB |
| `CONFIG_NFT_FIB_INET` | m | Inet FIB |
| `CONFIG_NFT_PKTTYPE` | m | Packet type matching |
| `CONFIG_NFT_LOG` | m | Logging |
| `CONFIG_NFT_REJECT` | m | Reject packets |
| `CONFIG_NFT_COMPAT` | m | iptables compatibility (Docker) |

### iptables Compatibility

Docker uses iptables-nft backend.

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_IP_NF_IPTABLES` | m | iptables core |
| `CONFIG_IP_NF_FILTER` | m | Filter table |
| `CONFIG_IP_NF_NAT` | m | NAT table |
| `CONFIG_IP_NF_TARGET_MASQUERADE` | m | MASQUERADE target |
| `CONFIG_IP_NF_TARGET_REDIRECT` | m | REDIRECT target |
| `CONFIG_IP6_NF_IPTABLES` | m | ip6tables core |
| `CONFIG_IP6_NF_FILTER` | m | IPv6 filter table |
| `CONFIG_IP6_NF_TARGET_MASQUERADE` | m | IPv6 MASQUERADE |
| `CONFIG_NF_NAT_IPV6` | m | IPv6 NAT |

### CONNMARK (Tailscale)

Tailscale uses CONNMARK for packet marking and policy routing.

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_NETFILTER_XT_CONNMARK` | m | CONNMARK target/match |
| `CONFIG_NETFILTER_XT_TARGET_CONNMARK` | m | Set connection mark |
| `CONFIG_NETFILTER_XT_MATCH_CONNMARK` | m | Match connection mark |
| `CONFIG_NET_ACT_CONNMARK` | m | TC action for connmark |

### Bridge / EBTABLES (Docker)

Docker bridge networking.

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_BRIDGE_NETFILTER` | m | Netfilter on bridge |
| `CONFIG_BRIDGE_NF_EBTABLES` | m | Ethernet bridge tables |
| `CONFIG_BRIDGE_NF_EBTABLES_LEGACY` | m | Legacy ebtables |
| `CONFIG_NF_CONNTRACK_BRIDGE` | m | Conntrack for bridges |
| `CONFIG_NETFILTER_XT_TARGET_CHECKSUM` | m | Checksum offload |
| `CONFIG_NETFILTER_XT_TARGET_LOG` | m | Logging target |

### Additional Matches

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_NETFILTER_XT_MATCH_ADDRTYPE` | m | Address type matching |
| `CONFIG_NETFILTER_XT_MATCH_CONNTRACK` | m | Conntrack state matching |
| `CONFIG_NETFILTER_XT_MATCH_CGROUP` | m | Cgroup matching |
| `CONFIG_NETFILTER_XT_MATCH_COMMENT` | m | Comment match |
| `CONFIG_NETFILTER_XT_TARGET_MARK` | m | Packet marking |
| `CONFIG_NETFILTER_XT_MATCH_IPVS` | m | IPVS matching |

### IP Virtual Server (Docker Swarm)

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_IP_VS` | m | IPVS core |
| `CONFIG_IP_VS_PROTO_TCP` | y | TCP load balancing |
| `CONFIG_IP_VS_PROTO_UDP` | y | UDP load balancing |
| `CONFIG_IP_VS_RR` | m | Round-robin scheduler |
| `CONFIG_IP_VS_NFCT` | y | Conntrack integration |

---

## Network Drivers

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_TUN` | m | TUN/TAP devices (VPN, Tailscale) |
| `CONFIG_VETH` | m | Virtual ethernet pairs (containers) |
| `CONFIG_BRIDGE` | m | Ethernet bridging |
| `CONFIG_MACVLAN` | m | MAC-based VLANs |
| `CONFIG_IPVLAN` | m | IP-based VLANs |
| `CONFIG_VXLAN` | m | VXLAN tunnels (overlay networks) |
| `CONFIG_GENEVE` | m | GENEVE tunnels |
| `CONFIG_WIREGUARD` | m | WireGuard VPN |
| `CONFIG_NET_UDP_TUNNEL` | m | UDP tunneling |

### Routing

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_IP_ADVANCED_ROUTER` | y | Policy routing |
| `CONFIG_IP_MULTIPLE_TABLES` | y | Multiple routing tables |
| `CONFIG_IP_ROUTE_MULTIPATH` | y | Multipath routing |
| `CONFIG_IPV6_MULTIPLE_TABLES` | y | IPv6 multiple tables |

---

## BPF / eBPF

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_BPF_JIT` | y | BPF JIT compiler |
| `CONFIG_BPF_JIT_ALWAYS_ON` | y | Always use JIT (performance) |
| `CONFIG_CGROUP_BPF` | y | BPF cgroup hooks |

---

## Virtualization (KVM/QEMU)

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_KVM` | y | KVM core |
| `CONFIG_KVM_AMD` | m | AMD-V support |
| `CONFIG_KVM_INTEL` | m | VT-x support |
| `CONFIG_VIRTIO` | y | VirtIO core |
| `CONFIG_VIRTIO_PCI` | m | VirtIO PCI transport |
| `CONFIG_VIRTIO_NET` | y | VirtIO network (built-in for fast boot) |
| `CONFIG_VIRTIO_BLK` | m | VirtIO block |
| `CONFIG_VIRTIO_CONSOLE` | m | VirtIO console |
| `CONFIG_VIRTIO_BALLOON` | m | Memory ballooning |
| `CONFIG_VIRTIO_GPU` | m | VirtIO GPU |
| `CONFIG_VIRTIO_INPUT` | m | VirtIO input |
| `CONFIG_VIRTIO_VSOCKETS` | m | VM sockets |
| `CONFIG_VIRTIO_FS` | m | VirtIO filesystem (virtiofs) |
| `CONFIG_VHOST` | y | Vhost core |
| `CONFIG_VHOST_NET` | y | Vhost networking |
| `CONFIG_VHOST_VSOCK` | y | Vhost vsock |
| `CONFIG_VHOST_VDPA` | y | Vhost vDPA |

### VFIO (GPU Passthrough)

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_VFIO` | y | VFIO core |
| `CONFIG_VFIO_PCI` | y | PCI device passthrough |
| `CONFIG_VFIO_VIRQFD` | y | IRQ forwarding |
| `CONFIG_VFIO_MDEV` | m | Mediated devices |

---

## AMD Platform

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_X86_AMD_PLATFORM_DEVICE` | y | AMD platform devices |
| `CONFIG_AMD_NB` | y | AMD northbridge |
| `CONFIG_AMD_IOMMU` | y | AMD IOMMU |
| `CONFIG_AMD_IOMMU_V2` | m | IOMMU v2 (PASID) |

---

## Memory Management

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_NR_CPUS` | 32 | Max CPU count |
| `CONFIG_NUMA` | y | NUMA support |
| `CONFIG_NUMA_BALANCING` | y | Automatic NUMA balancing |
| `CONFIG_NUMA_BALANCING_DEFAULT_ENABLED` | y | Enable by default |
| `CONFIG_TRANSPARENT_HUGEPAGE` | y | THP support |
| `CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS` | y | THP always on |
| `CONFIG_COMPACTION` | y | Memory compaction |
| `CONFIG_MIGRATION` | y | Page migration |

---

## Graphics

### NVIDIA (RTX 5090 Blackwell)

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_DRM` | y | DRM core |
| `CONFIG_DRM_NOUVEAU` | m | Nouveau (fallback/early boot) |
| `CONFIG_FB` | y | Framebuffer |
| `CONFIG_FRAMEBUFFER_CONSOLE` | y | Fbcon |
| `CONFIG_DRM_FBDEV_EMULATION` | y | Fbdev compat (NVIDIA 6.11+) |
| `CONFIG_SYSFB_SIMPLEFB` | y | Simple framebuffer |

### AMD (iGPU)

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_DRM_AMDGPU` | m | AMDGPU driver |
| `CONFIG_DRM_AMDGPU_SI` | y | Southern Islands |
| `CONFIG_DRM_AMDGPU_CIK` | y | Sea Islands |
| `CONFIG_DRM_AMDGPU_USERPTR` | y | Userspace pointers |

---

## Storage

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_BLK_DEV_NVME` | y | NVMe block device |
| `CONFIG_NVME_CORE` | y | NVMe core |
| `CONFIG_NVME_MULTIPATH` | y | NVMe multipath |

---

## USB

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_USB_XHCI_HCD` | y | USB 3.x |
| `CONFIG_USB_EHCI_HCD` | y | USB 2.0 |

---

## Media (Webcam/Elgato)

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_MEDIA_SUPPORT` | y | Media subsystem |
| `CONFIG_MEDIA_USB_SUPPORT` | y | USB media |
| `CONFIG_MEDIA_CAMERA_SUPPORT` | y | Camera support |
| `CONFIG_MEDIA_CONTROLLER` | y | Media controller API |
| `CONFIG_VIDEO_DEV` | m | V4L2 |
| `CONFIG_USB_VIDEO_CLASS` | m | UVC webcams |
| `CONFIG_V4L2_MEM2MEM_DEV` | m | Mem2mem |
| `CONFIG_VIDEOBUF2_CORE` | m | Videobuf2 |
| `CONFIG_VIDEOBUF2_V4L2` | m | Videobuf2 V4L2 |
| `CONFIG_INPUT_EVDEV` | m | Event devices |
| `CONFIG_SND_USB_AUDIO` | m | USB audio |

---

## Filesystems

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_FUSE_FS` | m | FUSE |
| `CONFIG_FUSE_DAX` | y | FUSE DAX |
| `CONFIG_FUSE_USERSPACE_HELPER` | y | FUSE helper |
| `CONFIG_CIFS` | m | SMB/CIFS |
| `CONFIG_CIFS_XATTR` | y | Extended attributes |
| `CONFIG_CIFS_ACL` | y | ACL support |
| `CONFIG_CIFS_DFS_UPCALL` | y | DFS referrals |
| `CONFIG_CIFS_FSCACHE` | y | Fscache integration |

---

## Crypto / TLS

Hardware-accelerated crypto for Wine/Proton TLS 1.3.

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_TLS` | y | Kernel TLS |
| `CONFIG_CRYPTO_USER_API_TLS` | y | Userspace TLS API |
| `CONFIG_CRYPTO_AES_X86_64` | m | AES (software) |
| `CONFIG_CRYPTO_AES_NI_INTEL` | m | AES-NI (hardware) |
| `CONFIG_CRYPTO_CHACHA20_X86_64` | m | ChaCha20 |
| `CONFIG_CRYPTO_POLY1305_X86_64` | m | Poly1305 |

---

## Gaming

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_FUTEX` | y | Futex (esync/fsync baseline) |
| `CONFIG_HIGH_RES_TIMERS` | y | High resolution timers |
| `CONFIG_IPV6` | y | IPv6 (Battle.net prefers v6) |

---

## Compression

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_KERNEL_ZSTD` | y | Zstd kernel compression |
| `CONFIG_ZSTD_COMPRESS` | y | Zstd compress |
| `CONFIG_ZSTD_DECOMPRESS` | y | Zstd decompress |

---

## IPv6 / IPsec

| Option | Value | Purpose |
|--------|-------|---------|
| `CONFIG_IPV6` | y | IPv6 core |
| `CONFIG_INET6_XFRM_MODE_TRANSPORT` | m | Transport mode |
| `CONFIG_INET6_XFRM_MODE_TUNNEL` | m | Tunnel mode |
| `CONFIG_INET6_XFRM_MODE_BEET` | m | BEET mode |
