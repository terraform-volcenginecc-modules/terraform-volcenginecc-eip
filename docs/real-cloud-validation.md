# Real-cloud validation status

## Current status

Static construction is complete and part of the real-cloud lifecycle has been executed. The module is not release-ready because Provider `0.0.65` fails tag-clearing idempotency and cannot complete the detach/rebind sequence required for address-preserving migration.

Latest execution record:

- Date: `2026-08-18`
- Region: `cn-beijing`
- Terraform: `1.15.4`
- Provider: `volcengine/volcenginecc 0.0.65`
- Allocation runs: `eipmod-20260818-130239`, `eipclear-20260818-130530`
- Binding runs: `bind-0818-1309`, `nat-0818-1316`
- Cleanup: every EIP, two disposable ECS instances, NAT Gateway, Security Group, Subnet, VPC, and system volumes created by these runs was destroyed; explicit EIP queries returned no matching allocation.

Verified results:

- Independent pay-by-traffic EIP create succeeded; the immediate second Plan returned `No changes`.
- Bandwidth/name/description/tag update and second-key addition succeeded; the second Plan returned `No changes`.
- Removing the second logical key destroyed only that EIP; the retained primary EIP kept its allocation ID and address and reached `No changes`.
- Final managed-EIP destroy succeeded with no matching allocation remaining.
- Binding an independent EIP to disposable ECS A with `release_with_instance=false` succeeded. Allocation `eip-fe7l7fg3vaps79iu5j230qar` and address `124.174.111.255` remained unchanged, readback reported ECS A, and the second Plan returned `No changes`.
- Binding an independent EIP to disposable NAT Gateway `ngw-e8rjx44fx5vk4ccy45o2z0a4` succeeded. Allocation `eip-fe7l8qt4k7i879iu5j6v25ff` and address `124.174.123.17` remained unchanged, readback reported `instance_type = "Nat"`, and the second Plan returned `No changes`. The EIP was destroyed before the NAT Gateway; an explicit allocation-ID query returned no result before the remaining target resources were destroyed.

Observed release blockers:

- Explicit tag clearing reached empty cloud readback, but the following Plan persistently proposed `tags = []` because the Provider normalized the empty set to `null`.
- Direct ECS A to ECS B rebinding failed with `InvalidEip.InstanceMismatch`.
- Returning configuration to the independent phase produced `0 changed`; Provider Optional+Computed state retained ECS A instead of issuing a detach.

The retained fixtures are:

- `tests/lifecycle`: allocation, in-place field update, map-key addition/removal, and final release.
- `tests/binding-migration`: independent EIP, ECS A binding, ECS A to ECS B migration, unbinding, NAT binding, and final unbinding while preserving one allocation ID and address.

## Release gates

### Independent allocation lifecycle

- Allocate an independent traffic-billed EIP and verify address, ID, status, bandwidth, billing type, ISP, project, and tags.
- Require a no-change plan immediately after Apply.
- Update bandwidth, name, description, and tags; then require another no-change plan.
- Add and remove a second map key and verify only the intended EIP changes.
- Clear tags and verify the Provider/cloud readback converges.
- Destroy and confirm every module-owned allocation ID has been released and no billable EIP remains.

### ECS and NAT binding lifecycle

- Start with an independent EIP and record its allocation ID and public address.
- Bind it to disposable ECS A with `release_with_instance=false`; verify cloud readback and a no-change plan.
- Remove the ECS A binding; require empty binding readback, unchanged identity values, and a no-change plan.
- Bind the detached address to disposable ECS B; reject any plan that replaces the EIP, and verify both recorded identity values remain unchanged.
- Bind the same EIP to a disposable public NAT Gateway, then verify readback, unchanged identity values, and a no-change plan.
- Remove the NAT binding and repeat the unbound readback and no-change checks.
- Destroy consumers in dependency order, destroy the EIP, and confirm no allocation or billing residue remains.

Passing the static fixture is not sufficient. The release record must include the plan summaries, all identity/readback outputs after each Apply, and the final cloud-side absence check.

### Existing EIP and load-balancer composition

- Validate one consumer with an externally owned EIP. Record the allocation ID/address before and after creating and destroying the consumer; both must remain unchanged.
- Do not manage one allocation from two Terraform resource addresses. To transfer ownership to this module, import it into this module's state first and review the resulting no-change plan.
- Validate CLB through the Provider-supported `ClbInstance` EIP binding when that path is claimed.
- Validate NLB by passing the allocation ID to the NLB resource's `zone_mappings.ipv_4_eip_id`. The EIP Provider schema has no `NlbInstance` binding type.
- For an externally owned NLB EIP, destroying NLB must leave the EIP allocated. For a module-owned EIP in a combined composition, NLB must be destroyed before the EIP.

## Release-protection decision

The accepted PRD boundary is ECS-scoped only:

- `release_with_instance` controls whether a pay-as-you-go EIP bound to ECS is released when that ECS instance is deleted or recycled.
- The migration acceptance fixture explicitly uses `false` so the fixed public address is retained while moving between targets.
- This is not general deletion protection. The Provider exposes no property that prevents Terraform from deleting an EIP removed from configuration or included in `terraform destroy`.
- NAT, CLB, NLB, and externally owned EIP compositions therefore have no module-level release-protection switch. Ownership and destroy order must be explicit.

This boundary must remain visible in release documentation; the module must not claim generic release protection.

## Known boundaries

- Subscription and write-only fields require separate real-cloud validation before they are recommended for production use.
- Omitting an Optional+Computed binding from configuration counts as unbinding only after a real-cloud plan/apply/readback proves it. If the Provider retains the previous `instance_type` or `instance_id`, release is blocked until the Provider/module unbind behavior is corrected.
- Static plans use fake credentials and `-refresh=false`; they prove configuration and schema compatibility only.
