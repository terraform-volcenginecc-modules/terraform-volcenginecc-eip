# NLB composition and existing EIP reuse

Creates an internet-facing NLB and passes `module.eip.allocation_ids["nlb"]` to `zone_mappings.ipv_4_eip_id`. NLB attachment is modeled on the NLB resource because `NlbInstance` is not a supported `volcenginecc_vpc_eip.instance_type` value.

By default, the EIP module creates the address and owns its lifecycle. Set `existing_eip_id` to reuse an existing address instead:

```hcl
existing_eip_id = "eip-..."
```

In reuse mode, `existing_eip_ids` reads the address without adopting it as a Terraform-managed EIP resource. The caller remains responsible for the external address. Destroying this example deletes the NLB but does not release that EIP. Do not also manage the same EIP allocation in another Terraform resource.

This single-EIP example deliberately accepts exactly one zone mapping. A multi-zone public NLB should provide one independently managed or externally owned EIP per zone rather than reuse one allocation across multiple mappings.
