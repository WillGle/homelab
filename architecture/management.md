# Management Plane

The management plane provides controlled access to and observability of the
infrastructure itself: metal, virtualization, network, and storage. It is shown
as a generic plane in the [platform boundary diagram](../diagrams/platform.drawio)
and as a logical zone in the [network view](../diagrams/network.drawio).

## Design intent

- Keep infrastructure administration separate from workload traffic where
  the verified network allows it.
- Provide stable management access for operators and automation.
- Record changes and verification evidence in the repository.
- Expose infrastructure capacity to platform/workload owners through
  documented profiles and capabilities, without taking ownership of
  application deployment.
- Keep recovery and backup procedures tied to verified systems and tested
  recovery evidence.

Management addresses, access paths, monitoring, and backup mechanisms remain
unknown until they are checked against the live environment.
