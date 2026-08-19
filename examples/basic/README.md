# Basic example

Allocates one independent traffic-billed EIP with 5 Mbps peak bandwidth. It does not bind the EIP to another resource.

After applying, pass `module.eip.allocation_ids["primary"]` to a downstream ECS, NAT Gateway, or load-balancer module.
