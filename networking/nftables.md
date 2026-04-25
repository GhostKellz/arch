# nftables.md

nftables configuration for performance and security.

---

## Kernel Requirements

```
CONFIG_NF_TABLES=y
CONFIG_NF_TABLES_INET=y
CONFIG_NF_TABLES_IPV4=y
CONFIG_NF_TABLES_IPV6=y
CONFIG_NFT_CT=m
CONFIG_NFT_NAT=m
CONFIG_NFT_MASQ=m
CONFIG_NFT_LOG=m
CONFIG_NFT_REJECT=m
CONFIG_NFT_COMPAT=m              # iptables-nft compatibility
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
```

For Tailscale/Docker CONNMARK support:
```
CONFIG_NETFILTER_XT_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NET_ACT_CONNMARK=m
```

---

## Performance Tuning

### Connection Tracking

```bash
# /etc/sysctl.d/99-nftables.conf

# Increase conntrack table size for high-throughput
net.netfilter.nf_conntrack_max = 262144

# Reduce timeouts for faster cleanup
net.netfilter.nf_conntrack_tcp_timeout_established = 3600
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 30
net.netfilter.nf_conntrack_udp_timeout = 30
net.netfilter.nf_conntrack_udp_timeout_stream = 60

# Enable conntrack helpers only when needed
net.netfilter.nf_conntrack_helper = 0
```

### Hash Table Sizing

```bash
# Larger hash table for faster lookups
net.netfilter.nf_conntrack_buckets = 65536
```

---

## Security Baseline

### Basic Firewall Rules

```nft
#!/usr/sbin/nft -f
# /etc/nftables.conf

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow established/related
        ct state established,related accept

        # Allow loopback
        iif lo accept

        # Drop invalid
        ct state invalid drop

        # ICMP/ICMPv6 (ping, path MTU, etc)
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept

        # SSH (rate limited)
        tcp dport 22 ct state new limit rate 4/minute accept

        # Tailscale
        udp dport 41641 accept

        # Log dropped
        log prefix "nft-drop: " flags all counter drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;

        # Allow established/related
        ct state established,related accept

        # Docker/container forwarding (if needed)
        # iifname "docker0" accept
        # oifname "docker0" accept
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

### Anti-Spoofing

```nft
table inet raw {
    chain prerouting {
        type filter hook prerouting priority -300; policy accept;

        # Drop packets with invalid source
        fib saddr . iif oif missing drop

        # Drop fragments (optional, can break some apps)
        # ip frag-off & 0x1fff != 0 drop
    }
}
```

---

## Docker Compatibility

Docker uses iptables-nft backend. Ensure:

1. `CONFIG_NFT_COMPAT=m` in kernel
2. Don't flush Docker's chains manually
3. Docker creates its own chains - leave them alone

Check Docker chains:
```bash
sudo nft list ruleset | grep -A5 DOCKER
```

---

## Tailscale Integration

Tailscale manages its own rules. Key requirements:

1. CONNMARK modules loaded
2. UDP 41641 allowed inbound (or Tailscale uses DERP relay)
3. Don't block Tailscale's MASQUERADE rules

Check Tailscale rules:
```bash
sudo nft list ruleset | grep -i tailscale
sudo iptables -t nat -L -n | grep -i tailscale
```

---

## Diagnostics

```bash
# List all rules
sudo nft list ruleset

# List with counters
sudo nft list ruleset -a

# Check conntrack table
sudo conntrack -L
sudo conntrack -C

# Monitor in real-time
sudo conntrack -E

# Check module status
lsmod | grep nf_

# Reload rules
sudo nft -f /etc/nftables.conf
```

---

## Service Management

```bash
# Enable nftables service
sudo systemctl enable --now nftables

# Reload rules
sudo systemctl reload nftables

# Check status
sudo systemctl status nftables
```
