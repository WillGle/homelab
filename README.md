# Homelab Private Cloud

A 2-node Proxmox/KVM homelab, currently set up manually. This repository is the
handoff spec for turning that manual setup into Infrastructure as Code (IaC) —
it documents what exists and the rules for any human or agent automating it.

![Homelab Architecture](diagrams/architecture.svg)

## Goal

Convert a manually configured Proxmox/KVM environment into a version-controlled,
repeatable Infrastructure-as-Code setup (cloud-init, Ansible, Terraform),
without disrupting what's currently running.

## How this repo is organized

| File / directory | Purpose |
| --- | --- |
| [STATE.md](STATE.md) | Current state of the homelab, as verified against the real machines. The single source of truth for "what exists today." |
| `inventory/` | Machine-readable data (nodes, network, storage) describing the current environment. Source of truth once populated — do not duplicate these values elsewhere. |
| `diagrams/` | Architecture diagrams. |

## Principles

- `STATE.md` and `inventory/` describe only what has been verified against the
  real machines — never planned or assumed values.
- Anything not yet verified is marked `[UNVERIFIED]` or `[PLANNED]`, never
  stated as fact.
- Prefer machine-readable data (`inventory/*.yaml`) over prose for anything an
  automation agent needs to consume.

## Status

See [STATE.md](STATE.md) for current state.
