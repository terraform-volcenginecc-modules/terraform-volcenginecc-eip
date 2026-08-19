# terraform-volcenginecc-eip

Terraform module for allocating one or more Volcengine Elastic IP addresses, or reading explicitly identified existing EIPs, with stable logical keys and Provider-supported bindings.

## Scope

The module supports:

- independent EIP allocation;
- subscription, pay-by-bandwidth, and pay-by-traffic billing inputs;
- bandwidth, ISP line, project, name, description, and tags;
- optional binding to ECS, NAT Gateway, network interface, CLB, or HaVip through the EIP Resource's `instance_type` and `instance_id` fields.
- read-only reuse of explicitly identified external EIPs through `existing_eip_ids` without adopting or releasing them.

The Provider EIP schema does not expose general deletion protection, so this module does not claim to protect an EIP from `terraform destroy` or removal of a managed map key. `release_with_instance` controls only whether a pay-as-you-go EIP bound to ECS is released with that ECS instance. It must be set explicitly for that binding; use `false` when the address must survive ECS deletion. Existing EIPs are never silently adopted: `existing_eip_ids` reads them without ownership, or they can be explicitly imported into a managed key.

## Usage

```hcl
module "eips" {
  source  = "volcengine/eip/volcenginecc"
  version = "~> 1.0"

  name_prefix = "application"
  eips = {
    outbound = {
      billing_type = 3
      bandwidth    = 10
    }
  }

  common_tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

Provider authentication and region configuration belong in the caller. Never put access keys in module configuration.

## Optional binding

```hcl
eips = {
  ecs = {
    billing_type         = 3
    bandwidth            = 20
    instance_type        = "EcsInstance"
    instance_id          = module.ecs.instance_id
    release_with_instance = false
  }
  nat = {
    billing_type  = 2
    bandwidth     = 50
    instance_type = "Nat"
    instance_id   = module.nat_gateway.nat_gateway_id
  }
}
```

For a pay-as-you-go ECS binding, `release_with_instance` is mandatory. It must be omitted for NAT, CLB, ENI, HaVip, and subscription EIPs because the Provider does not expose equivalent release behavior for those targets.

## Existing EIP reuse

```hcl
module "eips" {
  source  = "volcengine/eip/volcenginecc"
  version = "~> 1.0"

  existing_eip_ids = {
    nlb = var.existing_eip_id
  }
}

# The NLB resource owns the association; the EIP remains externally owned.
resource "volcenginecc_clb_nlb" "this" {
  # ...
  zone_mappings = [{
    # ...
    ipv_4_eip_id = module.eips.allocation_ids["nlb"]
  }]
}
```

Destroying this module removes only the data-source read for `existing_eip_ids`; it does not release the external EIP. Import an external allocation into `volcenginecc_vpc_eip.this[<key>]` only when ownership should deliberately move to this module.

Changing a map key changes the Terraform resource address and normally releases and recreates that EIP. Keep keys stable and change `name` for display-name changes.

## Examples

- [basic](examples/basic): one independent traffic-billed EIP.
- [complete](examples/complete): independent allocation plus required disposable ECS and NAT binding targets.
- [existing-eip-nlb](examples/existing-eip-nlb): reads an external EIP without ownership and supplies its allocation ID to an NLB association.

## Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| `volcengine/volcenginecc` | `>= 0.0.60` |

The EIP Resource schema is unchanged between Provider `0.0.60` and the inspected `0.0.62` source at commit `592e4d1`. Real-cloud lifecycle acceptance is not complete; see [real-cloud validation](docs/real-cloud-validation.md).

## Inputs

| Name | Type | Default | Required | Description |
|---|---|---:|---:|---|
| `eips` | `map(object(...))` | `{}` | No | Module-owned EIPs keyed by stable logical names. At least one of `eips` or `existing_eip_ids` must be non-empty. |
| `existing_eip_ids` | `map(string)` | `{}` | No | Existing EIPs read without ownership, keyed by stable logical names. |
| `name_prefix` | `string` | `null` | No | Prefix for generated names. |
| `common_tags` | `map(string)` | `{}` | No | Tags applied to all EIPs. |

Each EIP supports `billing_type`, `bandwidth`, `isp`, `name`, `description`, `project_name`, `tags`, and optional binding attributes. `billing_type` values are 1 (subscription), 2 (pay by bandwidth), and 3 (pay by traffic). Traffic billing is limited to 200 Mbps by the Provider schema description.

Subscription-only inputs are `period`, `period_unit`, `renew_type`, and `renew_period_times`. These and `direct_mode` are write-only Provider properties and require focused real-cloud idempotency verification before production publication.

Binding attributes:

| Attribute | Description |
|---|---|
| `instance_type` | `Nat`, `NetworkInterface`, `ClbInstance`, `EcsInstance`, or `HaVip`. |
| `instance_id` | ID of the target resource; required together with `instance_type`. |
| `private_ip_address` | Optional only for ECS or network-interface binding. |
| `direct_mode` | Optional Provider write-only passthrough binding mode. |
| `release_with_instance` | Provider option for bound pay-as-you-go ECS EIPs; this is not general release protection. |

## Outputs

| Name | Description |
|---|---|
| `allocation_ids` | Stable logical keys to EIP allocation IDs. |
| `eip_addresses` | Stable logical keys to public IPv4 addresses. |
| `created_allocation_ids` | IDs of EIPs owned by this module. |
| `existing_allocation_ids` | IDs of external EIPs read without ownership. |
| `eips` | Detailed allocation, ownership, billing, binding, health, and tag information. |

## Operational notes

- Binding an EIP mutates network access and must be tested with disposable target resources first.
- `release_with_instance = false` preserves a pay-as-you-go EIP when its bound ECS is deleted; it is not general Terraform deletion protection. A managed EIP is still released when its map key or this module is destroyed.
- Workload migration must preserve the managed EIP key and allocation identity, but Provider `0.0.65` cannot currently complete the required detach/rebind lifecycle: direct ECS-A to ECS-B update is rejected by the cloud API, while omitting Optional+Computed binding fields does not detach. Treat migration as release-blocked until Provider-supported unbinding is available.
- `existing_eip_ids` is read-only composition. Existing keys never create, update, bind, unbind, or release the referenced EIP.
- The EIP Resource does not accept an NLB instance type. For NLB, pass `allocation_ids` into the NLB `zone_mappings[*].ipv_4_eip_id`; the NLB owns that association.
- The Module always supplies both tag key and value. Omit per-EIP `tags` and leave `common_tags` empty to leave tags unmanaged; set per-EIP `tags = {}` with empty `common_tags` to explicitly clear previously managed tags.
- `isp` and `project_name` are replacement-triggering Provider fields when configured.
- Import with `terraform import 'module.eips.volcenginecc_vpc_eip.this["outbound"]' eip-xxxxxxxx`.
- Apply must be followed by a second plan that reports no changes before release. Explicit tag clearing currently reaches empty cloud state but Provider `0.0.65` reads it as `null`, producing a persistent `tags = []` plan; this is a release blocker.
