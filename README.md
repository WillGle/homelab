# Homelab Private Cloud

A 2-node Proxmox/KVM homelab designed to simulate a small private-cloud virtualization layer.

The goal of this project is not only to run self-hosted services, but to document and gradually automate the lifecycle of a virtualization platform: physical nodes, Proxmox/KVM, VM provisioning, storage, networking, monitoring, backup, and failure recovery.

## Objectives

- Build a small private-cloud infrastructure lab using Proxmox VE and KVM.
- Treat physical machines as a virtualized compute pool.
- Document architecture, networking, storage, VM lifecycle, and operations.
- Gradually move from manual setup to automation using cloud-init, Ansible, Terraform, and scripts.
- Use the lab as a learning platform for System Engineering, virtualization, infrastructure automation, and on-prem operations.

## Architecture Overview

```mermaid
flowchart TD
    Internet[Internet]
    Router[ISP Router / WiFi Box<br/>Gateway: 192.168.1.1]
    Switch[TP-Link TL-SG108E<br/>8-port Easy Smart Switch]

    Admin[Admin Laptop / Desktop<br/>SSH / Proxmox Web UI / Git]

    PVE01[pve01-pc<br/>Ryzen 5600X / 16GB RAM / Gigabyte RTX 2060 OC 6GB<br/>Primary Compute & Storage Node]
    PVE02[pve02-mini<br/>Intel i5-6500T / 24GB RAM<br/>Secondary Compute (Hosting & Lab)]

    Cluster[Proxmox Cluster<br/>homelab]

    Storage01[pve01 Storage<br/>256GB NVMe OS<br/>256GB SSD VM Pool<br/>4TB x2 ZFS Mirror]
    Storage02[pve02 Storage<br/>256GB Local Disk]

    NAS[nas-01<br/>NAS / NFS / SMB]
    Monitoring[monitoring-01<br/>Prometheus / Grafana]
    K3S[k3s-01<br/>Single-node K3s for Learning]
    ML[ml-compute-01<br/>Ollama & Thesis ML Compute]
    DevOps[devops-01<br/>CI/CD Testbed]

    Repo[GitHub Homelab Repo<br/>Documentation & Setup Notes]

    Internet --> Router --> Switch
    Switch --> Admin
    Switch --> PVE01
    Switch --> PVE02

    PVE01 --> Cluster
    PVE02 --> Cluster

    PVE01 --> Storage01
    PVE02 --> Storage02

    Storage01 --> NAS
    PVE02 --> Monitoring
    PVE02 --> K3S
    PVE01 --> ML
    PVE02 --> DevOps

    Tailnet[Tailscale VPN<br/>Overlay: 100.64.0.0/10]
    Admin -.VPN.-> Tailnet
    Tailnet -.VPN.-> PVE01
    Tailnet -.VPN.-> PVE02

    Repo -.documents.-> Cluster
```

## Physical Inventory

| Node         | Role                       | Hardware                               | Storage                           | Notes                              |
| ------------ | -------------------------- | -------------------------------------- | --------------------------------- | ---------------------------------- |
| `pve01-pc`   | Primary Compute & Storage | Ryzen 5 5600X, 16GB DDR4, Gigabyte GeForce RTX 2060 OC 6GB GDDR6 | 256GB NVMe, 256GB SSD, 4TB HDD x2 | Powerful CPU/GPU node, dual-role  |
| `pve02-mini` | Secondary Compute (Lab)    | Intel Core i5-6500T, 24GB DDR4         | 256GB disk                        | Hosting & learning testbed/labo    |
| `switch-01`  | L2 network                 | TP-Link TL-SG108E (8-port Easy Smart)  | N/A                               | Flat LAN                           |
| `router-01`  | Gateway                    | ISP WiFi box/router                    | N/A                               | NAT, DHCP/static lease             |

## Network Plan

Assumed LAN:

```text
192.168.1.0/24
Gateway: 192.168.1.1
```

| Host             |         LAN IP |   Tailscale IP | Role                       |
| ---------------- | -------------: | -------------: | -------------------------- |
| `router-01`      |  `192.168.1.1` |            N/A | Gateway                    |
| `pve01-pc`       | `192.168.1.10` | `100.64.1.10`  | Proxmox host               |
| `pve02-mini`     | `192.168.1.11` | `100.64.1.11`  | Proxmox host               |
| `nas-01`         | `192.168.1.20` |            N/A | NAS / storage service      |
| `monitoring-01`  | `192.168.1.30` |            N/A | Prometheus / Grafana       |
| `k3s-01`         | `192.168.1.40` |            N/A | k3s single-node (learning) |
| `ml-compute-01`  | `192.168.1.41` |            N/A | Dedicated ML Compute       |
| `devops-01`      | `192.168.1.50` |            N/A | CI/CD testbed              |
| `Admin laptop`   |   `192.168.1.x` |  `100.64.1.50` | Admin Workstation          |

VM traffic path:

```text
VM NIC -> tap interface -> vmbr0 (Linux Bridge) -> eno1 (Physical NIC) -> 1Gbps Switch -> Router / LAN
```

### Physical Port Allocation (TL-SG108E Switch)

| Switch Port | Connected Device | Cable Type | Speed | Config / VLAN |
| ----------- | ---------------- | ---------- | ----- | ------------- |
| **Port 1**  | `router-01` (LAN) | Cat6 UTP   | 1Gbps | Access VLAN 1 (Default) |
| **Port 2**  | `Admin Workstation` | Cat6 UTP   | 1Gbps | Access VLAN 1 (Default) |
| **Port 3**  | `pve01-pc` (`eno1`) | Cat6 UTP   | 1Gbps | Trunk (VLAN 1 Untagged) |
| **Port 4**  | `pve02-mini` (`eno1`) | Cat6 UTP   | 1Gbps | Trunk (VLAN 1 Untagged) |
| **Port 5-8**| *Spare / Unused* | N/A        | -     | N/A |

### Proxmox VE Network Configuration

The physical network interface (`eno1`) is bound to a virtual bridge (`vmbr0`) which acts as a virtual switch. VMs attach their virtual interfaces to `vmbr0`.

#### `pve01-pc` Config (`/etc/network/interfaces`)

```text
auto lo
iface lo inet loopback

iface eno1 inet manual
# Physical port connected to Switch Port 3

auto vmbr0
iface vmbr0 inet static
        address 192.168.1.10/24
        gateway 192.168.1.1
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
# Management IP and VM traffic bridge
```

#### `pve02-mini` Config (`/etc/network/interfaces`)

```text
auto lo
iface lo inet loopback

iface eno1 inet manual
# Physical port connected to Switch Port 4

auto vmbr0
iface vmbr0 inet static
        address 192.168.1.11/24
        gateway 192.168.1.1
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
# Management IP and VM traffic bridge
```

### Remote Access & Management (Tailscale VPN)

To securely manage the Proxmox cluster remotely without exposing ports to the public internet, **Tailscale** is installed directly on the hypervisor host nodes (`pve01-pc` and `pve02-mini`).

- **Tailscale Daemon**: Runs directly in the host OS (Debian-based PVE) to handle wireguard encapsulation.
- **Tailnet IPs**:
  - `pve01-pc`: `100.64.1.10`
  - `pve02-mini`: `100.64.1.11`
- **Access Control**: Administrative workstations authenticate to the tailnet to access SSH (`port 22`) and the Proxmox Web UI (`port 8006`).
- **Tailscale Virtual Interface (`tailscale0`)**: Configured automatically upon connection and handles packet routing securely inside the host network namespaces.

## Storage Design

### `pve01-pc`

| Disk       | Usage                                               |
| ---------- | --------------------------------------------------- |
| 256GB NVMe | Proxmox OS                                          |
| 256GB SSD  | Fast VM pool / templates / test workloads           |
| 4TB HDD x2 | ZFS mirror for NAS, backups, ISO archive, bulk data |

Planned storage pool:

```text
tank
type: ZFS mirror
members: 4TB HDD + 4TB HDD
```

### `pve02-mini`

| Disk       | Usage                         |
| ---------- | ----------------------------- |
| 256GB disk | Proxmox OS + local VM storage |

Ceph is intentionally not used in the first version because this is a 2-node lab with 1Gbps networking. The initial focus is VM lifecycle, storage mapping, backup/restore, and operational clarity.

## Virtualization Layer

Platform:

```text
Proxmox VE
KVM/QEMU
Linux bridge networking
Local/ZFS-backed storage
PCIe GPU Passthrough (Gigabyte GeForce RTX 2060 OC 6GB GDDR6)
```

Cluster:

```text
Cluster name: homelab
Nodes:
- pve01-pc (Ryzen 5 5600X, 16GB RAM, Gigabyte GeForce RTX 2060 OC 6GB GDDR6) - Primary Compute & Storage
- pve02-mini (Intel Core i5-6500T, 24GB RAM) - Secondary Compute (Hosting & Testbed/Lab)
```

Important limitation:

```text
This is a 2-node cluster for learning centralized management.
It is not treated as production-grade HA.
HA is disabled unless a third quorum vote/qdevice is added.
```

## Planned Workloads

| VM/LXC           | Node         | Purpose                              | Suggested Resources |
| ---------------- | ------------ | ------------------------------------ | ------------------- |
| `nas-01`         | `pve01-pc`   | NAS / NFS / SMB                      | 2 vCPU, 2–4GB RAM   |
| `monitoring-01`  | `pve02-mini` | Prometheus, Grafana, exporters       | 2 vCPU, 4GB RAM     |
| `k3s-01`         | `pve02-mini` | Single-node K3s (pods, heal, LB lab) | 2 vCPU, 4GB RAM     |
| `ml-compute-01`  | `pve01-pc`   | Local Ollama & Thesis ML Compute     | 4 vCPU, 8GB RAM + GPU |
| `devops-01`      | `pve02-mini` | Jenkins/GitLab Runner/Docker testbed | 2 vCPU, 4GB RAM     |

## Repository Structure

```text
homelab-private-cloud/
├── README.md
├── docs/
│   ├── 00-overview.md
│   ├── 01-architecture.md
│   ├── 02-networking.md
│   ├── 03-storage.md
│   ├── 04-proxmox-cluster.md
│   ├── 05-vm-lifecycle.md
│   ├── 06-monitoring.md
│   ├── 07-backup-restore.md
│   └── 08-incident-runbooks.md
│
├── inventory/
│   ├── nodes.yaml
│   ├── vms.yaml
│   └── networks.yaml
│
├── diagrams/
│   ├── architecture.drawio
│   ├── network.drawio
│   └── storage.drawio
│
├── scripts/
│   ├── check-health.sh
│   ├── backup-vm.sh
│   └── collect-info.sh
│
├── cloud-init/
│   └── ubuntu-template.yaml
│
├── ansible/
│   ├── inventory.ini
│   └── playbooks/
│
├── terraform/
│   └── proxmox/
│
└── incidents/
    ├── vm-network-down.md
    └── storage-full.md
```

## Current Status

This lab is currently being rebuilt and documented from a mostly manual Proxmox setup.

The first milestone is documentation-first:

* [ ] Define physical inventory
* [ ] Define IP plan
* [ ] Reinstall Proxmox on both nodes
* [ ] Create 2-node Proxmox cluster
* [ ] Configure storage pools
* [ ] Create VM template
* [ ] Deploy monitoring VM
* [ ] Document network and storage design
* [ ] Add basic health-check scripts

Automation will be added incrementally after the base system is stable.

## Automation Roadmap

### Phase 1 — Manual but documented

* Install Proxmox on both nodes.
* Configure static IPs.
* Create cluster.
* Configure bridge networking.
* Configure local/ZFS storage.
* Document every decision.

### Phase 2 — Script-assisted operations

* Add health-check scripts.
* Add backup scripts.
* Add inventory files.
* Add restore runbooks.

### Phase 3 — Cloud-init VM templates

* Create Ubuntu/Debian cloud-image templates.
* Inject hostname, SSH key, user, and qemu-guest-agent using cloud-init.
* Stop installing each VM manually through console.

### Phase 4 — Ansible bootstrap

* Configure common packages.
* Install Docker.
* Install node exporter.
* Configure users, SSH, firewall, and baseline services.

### Phase 5 — Terraform provisioning

* Create Proxmox VMs using Terraform.
* Use cloud-init for first boot.
* Use Ansible for post-boot configuration.

### Phase 6 — Failure lab

* Simulate VM network failure.
* Simulate storage pressure.
* Simulate node reboot.
* Write incident reports with symptoms, root cause, fix, and prevention.

### Phase 7 — PXE / automated bare-metal provisioning

* Document PXE/iPXE flow.
* Add Proxmox answer-file notes.
* Optional: implement unattended Proxmox install later.

## Operational Principles

* Prefer documentation over hidden manual knowledge.
* Prefer repeatable steps over one-time Web UI changes.
* Prefer inventory files over memory.
* Prefer VM templates over repeated OS installs.
* Prefer cloud-init and Ansible over manual SSH configuration.
* Prefer Terraform/API over Web UI for repeatable VM provisioning.
* Treat every failure as an incident report.

## Key Learning Areas

* Proxmox VE administration
* KVM/QEMU virtualization
* VM lifecycle management
* Linux bridge networking
* Storage planning with ZFS/NAS
* Backup and restore design
* Monitoring with Prometheus/Grafana
* Infrastructure documentation
* Configuration management with Ansible
* Infrastructure provisioning with Terraform
* Homelab operations and troubleshooting

## Why This Project Exists

This project is designed as a practical infrastructure lab for learning the virtualization layer of a private-cloud environment.

The long-term goal is to understand how physical compute, storage, and network resources are transformed into virtualized infrastructure that can be consumed by higher-level platforms such as Kubernetes, CI/CD systems, and internal developer platforms.
