# Platform Boundary

This document describes the desired architecture. It is intent, not a claim
that the design is already deployed.

Homelab is the private infrastructure fabric below the Software, Engineering,
Knowledge, and Media platforms. It supplies virtualized compute, storage,
network connectivity, and management capacity through workload contracts.

See the editable [platform boundary diagram](../diagrams/platform.drawio) for
this ownership and capacity flow.

```text
Work and projects
        ↓
Software · Engineering · Knowledge · Media platforms
        ↓ consume
Infrastructure contracts
        ↓ provided by
Homelab: compute · storage · network · management planes
        ↓ runs on
Bare metal
```

The boundary works in both directions: a platform can add or remove a workload
without redefining the infrastructure planes, and metal can be replaced or
added without assigning it to one application.

## Ownership

- Homelab owns physical and virtual capacity, infrastructure networking,
  storage services, and their management.
- Platform repositories own application deployment and runtime configuration.
- Work and project repositories own source, research artifacts, designs, and
  media content.
- A workload may consume more than one contract. WisdomTree belongs to the
  Knowledge Platform and may consume application, database, or optional AI
  capacity; it is not a Homelab service.

See [workload contracts](workload-contracts.md) and the
[provisioning lifecycle](../provisioning/README.md).
