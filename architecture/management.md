# Management Plane

The management plane provides controlled access to and observability of the
infrastructure itself: metal, virtualization, network, and storage.

## Design intent

- Keep infrastructure administration separate from workload traffic where
  the verified network allows it.
- Provide stable management access for operators and automation.
- Record changes and verification evidence in the repository.
- Expose infrastructure capacity to platform owners through documented
  contracts, without taking ownership of application deployment.
- Keep recovery and backup procedures tied to verified systems and tested
  recovery evidence.

Management addresses, access paths, monitoring, and backup mechanisms remain
unknown until they are checked against the live environment.
