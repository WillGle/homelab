# Storage Plane

This describes logical storage capabilities independently of their physical
placement. The [platform boundary diagram](../diagrams/platform.drawio) keeps
these capabilities separate from the reported hardware in the
[physical inventory view](../diagrams/physical.drawio).

| Class | Intended use | Required properties |
| --- | --- | --- |
| Hot | VM disks, databases, active scratch | Predictable latency and explicit capacity limits |
| Bulk | Engineering data, knowledge sources, and media | Capacity and suitable read/write throughput |
| Backup | Recovery copies for protected workloads | Independent recovery path and documented retention |

The [capability catalog](capabilities.md) describes storage and backup
properties; [workload profiles](workload-profiles.md) request the classes they
need. Physical devices, filesystems, pools, and protocols that provide those
capabilities are implementation decisions informed by verified inventory.

Do not treat the pool placement shown in the legacy diagram as a target
architecture. A future dedicated storage metal should not require platform
workloads to change their requested storage capabilities.
