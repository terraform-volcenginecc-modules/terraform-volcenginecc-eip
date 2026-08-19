# Complete example

Creates three EIPs on every apply:

- an independent address reserved for later composition;
- an address bound to the ECS instance supplied by `ecs_instance_id`;
- an address bound to the internet NAT Gateway supplied by `nat_gateway_id`.

Both target IDs are required, so this example cannot silently degrade into another independent-only example. The ECS instance and NAT Gateway must already exist and remain externally owned; destroying this example removes only the three EIPs. `release_with_instance = false` makes the ECS-specific release behavior explicit so deleting the ECS instance does not intentionally release its EIP with the instance.

```hcl
ecs_instance_id = "i-..."
nat_gateway_id  = "ngw-..."
```

For an externally owned EIP or an NLB composition, use the `existing-eip-nlb` example instead of importing the address into this complete example.
