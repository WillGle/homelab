# Network Plane

This describes logical connectivity requirements. Current physical topology
and network settings belong in inventory and must be live-verified.

The [network view](../diagrams/network.drawio) places the desired zones beside
the unverified reported LAN; the [physical inventory view](../diagrams/physical.drawio)
shows the reported host endpoints separately.

## Logical zones

- **Management** — Proxmox administration, SSH, and infrastructure APIs.
- **Service** — applications, databases, and internal APIs.
- **Storage** — file and block storage traffic where separation is needed.
- **Lab and IoT** — prototypes, sensors, and less-trusted devices.
- **Ingress** — explicitly exposed services and their entry points.

These are logical zones. VLANs, firewall policy, address ranges, and whether
some zones share a physical network are implementation decisions. The current
reported flat LAN is unverified and does not define the desired logical model.
