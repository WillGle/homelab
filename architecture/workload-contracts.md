# Workload Contracts

Contracts describe the infrastructure a workload class needs. They do not
assign a platform or application to a particular metal or guest. The
[platform boundary diagram](../diagrams/platform.drawio) shows where these
contracts sit between platform repositories and the infrastructure fabric.

```yaml
workload_classes:
  persistent_application:
    requires:
      - compute
      - persistent_storage
      - internal_network
      - backup

  database:
    requires:
      - compute
      - low_latency_storage
      - backup
      - internal_network

  engineering_compute:
    requires:
      - high_cpu
      - large_memory
      - scratch_storage
    optional:
      - gpu

  ai_compute:
    requires:
      - gpu
      - model_storage

  media:
    requires:
      - bulk_storage
      - high_network_throughput
      - authenticated_ingress
```

These class names and requirements are an initial design proposal. Resource
sizes, backup objectives, network policy, and service levels need to be agreed
before provisioning them.

Example platform mapping:

| Platform | Candidate contracts |
| --- | --- |
| Software | `persistent_application`, `database` |
| Knowledge | `persistent_application`, `database`, optional `ai_compute` |
| Engineering | `engineering_compute`, `bulk_storage` |
| Media | `media`, `bulk_storage` |

This mapping describes infrastructure needs only. Application configuration
and deployment remain with the platform.
