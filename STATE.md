# Current State

Last live verification: 2026-09-24
Verification method: Ansible over SSH through Tailscale.

## Proxmox metals

### pve-mini

- Proxmox VE: 9.2.2
- Kernel: 7.0.2-6-pve
- CPU: Intel Core i5-6500T
- Memory: 23907 MB
- LAN: 192.168.1.222/24 on vmbr0
- Tailscale: 100.71.142.105
- Running VMs: none
- Running LXCs: none

### pve-station

- Proxmox VE: 9.2.2
- Kernel: 7.0.2-6-pve
- CPU: AMD Ryzen 5 5600X
- Memory: 15915 MB
- LAN: 192.168.1.51/24 on vmbr0
- Tailscale: 100.107.148.30
- Running VMs: none
- Running LXCs: none

## Storage

Capacities below are the values reported by `pvesm status` in KiB
(total / used / available).

### pve-mini

| Proxmox storage | Type | Status | Total | Used | Available |
| --- | --- | --- | ---: | ---: | ---: |
| `backup-hdd` | dir | active | 960244192 | 2080 | 960225728 |
| `cold-archive` | dir | active | 1111917400 | 6276 | 1111861972 |
| `local` | dir | active | 40453376 | 4832188 | 33534072 |
| `local-lvm` | lvmthin | active | 56487936 | 0 | 56487936 |
| `mini-sata` | lvmthin | active | 229609472 | 0 | 229609472 |

Physical disks observed with `lsblk`: 223.6G LVM thin storage; two 465.8G ext4 disks, a 149.1G ext4 disk, and a 931.5G ext4 disk mounted under `/mnt/disks/`; 119.2G NVMe boot disk.

### pve-station

| Proxmox storage | Type | Status | Total | Used | Available |
| --- | --- | --- | ---: | ---: | ---: |
| `local` | dir | active | 98497780 | 7979292 | 85468940 |
| `local-lvm` | lvmthin | active | 354275328 | 0 | 354275328 |

Physical disks observed with `lsblk`: 465.8G Proxmox boot disk; two 3.6T disks with NTFS partitions; a 238.5G disk and a 238.5G NVMe, both with NTFS partitions. The NTFS disks are not listed as Proxmox storage by `pvesm status`.
