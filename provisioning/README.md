# Provisioning Lifecycle

This is the intended sequence from physical machines to generic infrastructure
capacity. A minimal [Ansible baseline playbook](ansible/playbooks/proxmox-baseline.yml)
is present; OpenTofu and cloud-init configuration are not implemented yet. The
[platform boundary diagram](../diagrams/platform.drawio) summarizes the capacity
hand-off at the end of this lifecycle.

```text
Verified inventory
       ↓
Manual Proxmox installation and bootstrap
       ↓
Management access and base host configuration
       ↓
Network and storage capacity
       ↓
Generic VMs or containers
       ↓
Guest initialization
       ↓
Workload profiles and capabilities consumed by platform/workload owners
```

## Boundaries

1. **Inventory first.** Verify the hardware, Proxmox version, network, storage,
   and running guests. Record evidence in `STATE.md` and `inventory/`.
2. **Physical bootstrap stays manual.** Install Proxmox, establish management
   connectivity, and install operator SSH keys before repository automation
   can reach a metal.
3. **Configure infrastructure.** Ansible may manage reviewed Proxmox host
   settings and infrastructure services after the live baseline is recorded.
   Changes to running guests, networking, GPU passthrough, or storage require
   an explicit, reviewed change procedure before implementation.
4. **Create generic capacity.** OpenTofu may manage virtual machines,
   containers, volumes, or networks through the Proxmox API once workload
   requirements and provider behavior are decided.
5. **Initialize guests.** Cloud-init may establish a guest OS baseline and
   return access to the platform/workload owner.
6. **Hand off by profile.** Platform/workload owners deploy applications and
   own their application data and runtime configuration.

Guest names should describe a workload profile or shared infrastructure role,
not an application name. No guest layout is selected yet. Kubernetes is not
part of the baseline; introducing it requires a separate decision based on
operational need.

## Implementation status

- Core Proxmox host, interface, disk, storage, and guest status: verified 2026-09-24; gateway/topology details remain unverified
- Manual Proxmox bootstrap: current status unknown
- Ansible inventory/configuration and the [Proxmox baseline playbook](ansible/playbooks/proxmox-baseline.yml) are present; OpenTofu and cloud-init are not implemented.
