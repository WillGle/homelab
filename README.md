# Homelab

Homelab is a **private infrastructure fabric** that provides compute, storage,
networking, and virtualization for the Software, Engineering, Knowledge, and
Media platforms.

```mermaid
flowchart TB
  work[Work and projects]
  subgraph owners[Platform / workload owners]
    software[Software]
    engineering[Engineering]
    knowledge[Knowledge]
    media[Media]
  end
  profiles[Workload profiles]
  capabilities[Infrastructure capabilities]
  subgraph homelab[Homelab infrastructure fabric]
    compute[Compute plane]
    storage[Storage plane]
    network[Network plane]
    management[Management plane]
  end
  metal[Bare metal capacity]
  work --> owners --> profiles --> capabilities --> homelab --> metal
```

## Scope

This repository describes and, later, may provision the infrastructure
capacity behind those platforms: physical machines, virtualization, compute,
storage, network, and infrastructure management.

Application source code, research and engineering projects, and media library
content belong to their owning platform or project repositories. Homelab records
the workload profiles and infrastructure capabilities those workloads need; it
does not own the workloads.

## Repository layers

| Path | Purpose |
| --- | --- |
| [inventory/](inventory/) | Reported physical and network facts, with verification status and source. |
| [architecture/](architecture/) | Platform boundary, infrastructure planes, capability catalog, and workload profiles. |
| [provisioning/](provisioning/) | The intended path from manually bootstrapped metal to generic capacity. |
| [STATE.md](STATE.md) | Facts directly verified against the live environment. |
| [diagrams/](diagrams/) | Editable desired-architecture and reported-inventory views. |
| [docs/legacy/](docs/legacy/) | Preserved v1 records that came from an unverified diagram. |

Inventory records inherited from the old diagram are explicitly marked
unverified. They are leads for a future live inventory pass, not current-state
claims. Architecture documents describe intent and do not assert that the
design has been implemented. No IaC is present yet.

## Start here

- [Architecture overview](architecture/platform.md)
- [Capability catalog](architecture/capabilities.md)
- [Workload profiles](architecture/workload-profiles.md)
- [Current state](STATE.md)
- [Provisioning lifecycle](provisioning/README.md)

## Diagrams

The `.drawio` files are editable source diagrams. They separate desired
architecture from reported, unverified inventory:

| View | Meaning |
| --- | --- |
| [Platform boundary](diagrams/platform.drawio) | Desired flow from platform/workload owners through profiles and capabilities to bare metal. |
| [Logical and reported network](diagrams/network.drawio) | Desired logical zones beside the historical flat-LAN report. |
| [Reported physical inventory](diagrams/physical.drawio) | Reported hosts and storage, with verification gaps called out. |
| [Legacy v1 topology redraw](docs/legacy/architecture-v1.drawio) | Readability redraw of the historical topology; not target architecture. |
