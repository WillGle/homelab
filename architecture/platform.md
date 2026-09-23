# Platform Boundary

This document describes the desired architecture. It is intent, not a claim
that the design is already deployed.

Homelab is the private infrastructure fabric below the Software, Engineering,
Knowledge, and Media platform/workload layer. It provides generic capacity
through infrastructure planes. Workloads request that capacity with reusable
profiles composed from capabilities.

See the editable [platform boundary diagram](../diagrams/platform.drawio) for
this ownership and capacity flow.

```text
Work and projects
        ↓
Platform / workload owners
(Software · Engineering · Knowledge · Media)
        ↓ request
Workload profiles
        ↓ require
Infrastructure capabilities
        ↓ provided by
Homelab: compute · storage · network · management planes
        ↓ supported by
Bare metal
```

The boundary works in both directions: a platform or project can add or remove
a workload without redefining the infrastructure planes, and metal can be
replaced or added without assigning it to one application. Platform/workload
ownership does not imply one repository per platform; an owner may span
multiple repositories and workloads.

## Ownership

- Homelab owns physical and virtual capacity, infrastructure networking,
  storage services, and their management.
- Platform/workload owners own application deployment and runtime
  configuration.
- Work and project repositories own source, research artifacts, designs, and
  media content.
- A workload may consume more than one profile. WisdomTree belongs to the
  Knowledge workload area and may consume persistent application, database,
  or optional AI inference capacity; it is not a Homelab service.

See the [capability catalog](capabilities.md),
[workload profiles](workload-profiles.md), and the
[provisioning lifecycle](../provisioning/README.md).
