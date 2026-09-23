# Workload Profiles

A workload profile is a reusable set of infrastructure capabilities requested
by a workload. A platform or project may use one or more profiles; profiles do
not assign workloads to a specific metal, guest, or repository. Capability
names are defined in the [capability catalog](capabilities.md).

```yaml
workload_profiles:
  persistent_web:
    requires:
      - compute.general
      - storage.hot
      - storage.bulk
      - storage.backup
      - network.internal
      - network.ingress

  database:
    requires:
      - compute.general
      - storage.hot
      - storage.backup
      - network.internal

  engineering_batch:
    requires:
      - compute.high_cpu
      - memory.large
      - storage.scratch
      - storage.bulk
    optional:
      - compute.gpu

  ai_inference:
    requires:
      - compute.general
      - storage.bulk
    optional:
      - compute.gpu

  media_service:
    requires:
      - compute.general
      - storage.bulk
      - network.ingress
      - network.high_throughput
    optional:
      - storage.backup
```

GPU is an optional acceleration capability for the general AI profile, not a
baseline requirement. A specific workload that cannot meet its requirements
without a GPU must declare that explicitly. CPU, memory, capacity, throughput,
backup, and availability targets remain to be sized after live inventory and
workload requirements are verified.

These are initial examples, not commitments to deploy these profiles or to
create one repository per platform. For example, a Knowledge workload such as
WisdomTree may request `persistent_web`, `database`, and optionally
`ai_inference`; an Engineering CFD job may request `engineering_batch`.
