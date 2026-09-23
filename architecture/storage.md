# Storage Plane

This describes logical storage services independently of their physical
placement. The [platform boundary diagram](../diagrams/platform.drawio) keeps
these contracts separate from the reported hardware in the
[physical inventory view](../diagrams/physical.drawio).

| Class | Intended use | Required properties |
| --- | --- | --- |
| Hot | VM disks, databases, active scratch | Predictable latency and explicit capacity limits |
| Bulk | Engineering data, knowledge sources, and media | Capacity and suitable read/write throughput |
| Backup | Recovery copies for protected workloads | Independent recovery path and documented retention |

Workload contracts state which storage classes and backup properties they
need. The physical devices, filesystems, pools, and protocols that provide
those classes are implementation decisions informed by verified inventory.

Do not treat the pool placement shown in the legacy diagram as a target
architecture. A future dedicated storage metal should not require platform
workloads to change their storage contract.
