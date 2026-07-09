# Current State

Source: `diagrams/architecture.drawio`. This reflects what the diagram
documents, not a live check against the hardware — treat it as
`[UNVERIFIED]` until confirmed with the commands in `AGENT.md`.

## Nodes

### pve01-pc

- Role: Compute & Storage Host
- CPU: AMD Ryzen 5 5600X
- RAM: 16GB DDR4
- LAN IP: 192.168.1.10
- Tailscale IP: 100.64.1.10
- NIC: `eno1` (physical, 1Gbps) → `vmbr0` (Linux bridge)

### pve02-mini

- Role: Secondary Compute (Hosting & Lab)
- CPU: Intel Core i5-6500T
- RAM: 24GB DDR4
- LAN IP: 192.168.1.11
- Tailscale IP: 100.64.1.11
- NIC: `eno1` (physical, 1Gbps) → `vmbr0` (Linux bridge)

## Network

- LAN subnet: 192.168.1.0/24 (flat)
- Gateway: router-01, 192.168.1.1
- Switch: switch-01, TP-Link TL-SG108E (8-port)
  - Port 1: uplink to router
  - Port 2: admin workstation
  - Port 3: trunk to pve01-pc
  - Port 4: trunk to pve02-mini
- Overlay: Tailscale — admin workstation reaches both nodes over the tailnet

## Storage

### pve01-pc storage

- 256GB — Proxmox boot (OS)
- 256GB SSD — fast VM storage
- ZFS mirror, 2x 4TB, pool `tank`
- GPU: RTX 2060 OC (Gigabyte, 6GB) — PCIe passthrough to `ml-compute-01`

### pve02-mini storage

- 256GB local disk — Proxmox OS & local VM storage

## Cluster

- Cluster name: homelab
- Nodes joined: pve01-pc, pve02-mini
- Sync: Corosync between the two nodes
- HA enabled: not shown in diagram — `[UNVERIFIED]`

## VMs / LXCs

| Name | Host node | IP | Purpose | Resources |
| --- | --- | --- | --- | --- |
| nas-01 | pve01-pc | 192.168.1.20 | NFS/SMB share, backed by `tank` | 2 vCPU, 4GB RAM |
| ml-compute-01 | pve01-pc | 192.168.1.41 | ML & thesis compute, GPU passthrough | 4 vCPU, 8GB RAM + GPU |
| monitoring-01 | pve02-mini | 192.168.1.30 | Prometheus / Grafana | 2 vCPU, 4GB RAM |
| k3s-01 | pve02-mini | 192.168.1.40 | Learning lab node | 2 vCPU, 4GB RAM |
| devops-01 | pve02-mini | 192.168.1.50 | CI/CD testbed | 2 vCPU, 4GB RAM |

## Services

No services beyond what's implied by the VM purposes above are documented.
