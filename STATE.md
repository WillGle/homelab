# Current State

Last live verification: 2026-09-24
Verification method: Ansible over SSH through Tailscale.

## Proxmox metals

### pve-mini

- Proxmox VE: 9.2.2
- Kernel: 7.0.2-6-pve
- CPU: Intel Core i5-6500T
- Memory: 23907 MB
- LAN: 192.168.1.222/24 on vmbr0 (DHCP)
- Default gateway: 192.168.1.1
- Tailscale: 100.71.142.105
- Proxmox cluster: standalone
- Running VMs: `lab-general-01` (VMID 100)
- Running LXCs: none
- VM templates: `ubuntu-2404-cloud` (VMID 9000)

### pve-station

- Proxmox VE: 9.2.2
- Kernel: 7.0.2-6-pve
- CPU: AMD Ryzen 5 5600X
- Memory: 15915 MB
- LAN: 192.168.1.51/24 on vmbr0 (static)
- Default gateway: 192.168.1.1
- Tailscale: 100.107.148.30
- Proxmox cluster: standalone
- Running VMs: none
- Running LXCs: none

## Guest and management

- `ubuntu-2404-cloud` is a Proxmox template on `pve-mini`; VMID 9000.
- `lab-general-01` is running on `pve-mini` as VMID 100: Ubuntu 24.04, `192.168.1.120/24`, DHCP, MAC `BC:24:11:68:12:A8`.
- Ansible SSH to the guest as `will` succeeds through `root@pve-mini` using ProxyJump.
- Cloud-init reports `done` with no errors, but `degraded` because the generated `user` field is deprecated.
- The guest's DHCP reservation has not been verified; the current lease may change.
- The Ansible host-baseline marker exists on both Proxmox hosts. The guest-baseline playbook is implemented, and `qemu-guest-agent` is active on the guest.

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
