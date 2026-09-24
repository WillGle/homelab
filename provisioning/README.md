# Provisioning Lifecycle

This describes the path from physical machines to generic infrastructure
capacity. The [Ansible host baseline](ansible/playbooks/proxmox-baseline.yml),
[Ubuntu cloud-init template](ansible/playbooks/build-ubuntu-template.yml),
[guest provisioning](ansible/playbooks/create-test-vm.yml), and [guest baseline](ansible/playbooks/guest-baseline.yml)
are implemented. OpenTofu is not implemented. The [platform boundary
diagram](../diagrams/platform.drawio) summarizes the capacity hand-off at the
end of this lifecycle.

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

- Ansible host baseline: implemented and verified on both standalone Proxmox
  hosts.
- Ubuntu cloud-init template: implemented and live-verified on `pve-mini` as
  VMID 9000.
- Cloud-init guest provisioning: implemented and live-verified for running
  VMID 100; cloud-init completed with a deprecated-user warning.
- Ansible guest baseline: implemented; guest SSH and the QEMU guest agent are
  live-verified.
- OpenTofu: not implemented.
- `lab-general-01` DHCP reservation: unverified; its current lease is
  `192.168.1.120`.
- LAN topology: partially verified; switch/router path is not inventoried.
- Proxmox CLI check mode: playbooks print a plan because `qm` mutations cannot
  be simulated; per-step checks allow interrupted template/VM creation to
  resume.
- Manual Proxmox bootstrap: current status unknown.
