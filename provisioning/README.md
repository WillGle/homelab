# Provisioning Lifecycle

This is the intended sequence from physical machines to generic infrastructure
capacity. It is a plan; no Ansible, OpenTofu, or cloud-init configuration is
implemented in this repository yet.

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
Infrastructure contracts consumed by platforms
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
   the safeguards in `AGENT.md`.
4. **Create generic capacity.** OpenTofu may manage virtual machines,
   containers, volumes, or networks through the Proxmox API once their
   contracts and provider behavior are decided.
5. **Initialize guests.** Cloud-init may establish a guest OS baseline and
   return access to the platform owner.
6. **Hand off by contract.** Platform repositories deploy applications and
   own their application data and runtime configuration.

Guest names should describe a workload class or shared infrastructure role,
not an application name. No guest layout is selected yet. Kubernetes is not
part of the baseline; introducing it requires a separate decision based on
operational need.

## Implementation status

- Live inventory: pending verification
- Manual Proxmox bootstrap: current status unknown
- Ansible, OpenTofu, and cloud-init: not implemented in this repository
