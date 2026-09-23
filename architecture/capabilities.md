# Infrastructure Capabilities

Capabilities describe independently requestable properties provided by the
compute, storage, network, and management planes. They are not workload
profiles, application identities, or claims about currently available
capacity. Names and properties below are an initial design proposal; capacity
and implementation must be established from verified inventory.

```yaml
capabilities:
  compute.general:
    resources: [cpu, memory]

  compute.high_cpu:
    resources: [cpu]

  compute.gpu:
    resources: [gpu]

  memory.large:
    resources: [memory]

  storage.hot:
    properties: [low_latency]

  storage.bulk:
    properties: [capacity]

  storage.scratch:
    properties: [temporary, high_throughput]

  storage.backup:
    properties: [recoverable]

  network.internal: {}
  network.ingress: {}
  network.high_throughput: {}
```

This catalog describes logical capabilities only. It does not prescribe a host,
VM, disk, VLAN, protocol, or service-level target. Workload profiles compose
these capabilities; the planes provide them from verified resources.
