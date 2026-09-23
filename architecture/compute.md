# Compute Plane

This describes desired compute capacity, not current placement.

The compute plane offers CPU, memory, and optional GPU capacity through
virtualization. Metal is selected by available capability and workload needs;
it is not assigned an application identity.

## Design intent

- Use generic guests or runtimes to provide the requested workload class.
- Keep placement decisions based on verified capacity, required resources, and
  resilience needs.
- Allow one guest to support multiple related services where their resource
  and failure requirements permit it.
- Treat GPU access as an optional capability with explicit passthrough and
  ownership constraints.
- Do not include Kubernetes in the baseline. Revisit orchestration only when
  scheduling across hosts, horizontal scaling, or rolling deployment becomes
  an established need.

Specific guest sizes, runtime choices, and placement rules remain undecided
until the live inventory and workload contracts are reviewed.
