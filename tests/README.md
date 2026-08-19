# Real-cloud acceptance

Static validation of these retained fixtures proves configuration and Provider-schema compatibility only. It does not prove cloud-side binding, update, readback, or release behavior.

The acceptance operator must check billing impact before Apply, use a unique `run_id`, and use only disposable ECS and NAT targets. Never run binding acceptance against production resources.

## Allocation lifecycle

Use `lifecycle/` in an isolated account:

1. Apply with `phase=create`.
2. Plan again with `phase=create`; require `No changes`.
3. Apply with `phase=update`; this changes bandwidth, name, description, and tags and adds a second EIP.
4. Plan again with `phase=update`; require `No changes`.
5. Apply with `phase=remove` to remove only the second EIP while preserving the updated primary EIP, then require another no-change plan.
6. Apply with `phase=clear` to clear all primary EIP tags, verify empty tag readback, then require another no-change plan.
7. Destroy and verify both allocation IDs are released.

The fixture uses pay-as-you-go billing and deliberately does not exercise subscription or write-only fields.

## Binding, unbinding, and migration

Use `binding-migration/` with two disposable ECS instance IDs and one disposable public NAT Gateway ID. Keep the same Terraform state throughout this sequence. After the first Apply, record both `allocation_id` and `eip_address`; every later phase must return exactly the same values.

`binding-targets/` can create those disposable prerequisites. Supply an available zone, public image, instance type, and a temporary password through environment variables or an uncommitted tfvars file. It creates no EIP. Destroy the EIP in `binding-migration/` before destroying `binding-targets/`, so no target is deleted while an acceptance EIP remains attached.

`existing-eip/` accepts an allocation ID created by another state and reads it through `existing_eip_ids`. Its plan must contain no EIP resource create, its output ownership must be `external`, and its destroy must leave the allocation available. This fixture was executed against the allocation created by `lifecycle/`.

1. Apply `phase=independent`, record the identity outputs, and require a no-change plan.
2. Apply `phase=ecs_a`; verify the EIP is bound to ECS A and require a no-change plan.
3. Apply `phase=independent`; verify the EIP is unbound, its identity is unchanged, and require a no-change plan.
4. Apply `phase=ecs_b`; verify the binding moved to ECS B without replacing the EIP and require a no-change plan.
5. Apply `phase=nat`; verify the same EIP is bound to the NAT Gateway and require a no-change plan.
6. Apply `phase=independent`; verify it is unbound again and require a no-change plan.
7. Destroy, then confirm the allocation ID no longer exists and no billable EIP remains.

Example commands, with the real target IDs supplied in a local auto tfvars file:

```shell
terraform -chdir=binding-migration init
terraform -chdir=binding-migration apply -var='run_id=<unique>' -var='phase=independent'
terraform -chdir=binding-migration output allocation_id
terraform -chdir=binding-migration output eip_address
terraform -chdir=binding-migration plan -detailed-exitcode -var='run_id=<unique>' -var='phase=independent'

terraform -chdir=binding-migration apply -var='run_id=<unique>' -var='phase=ecs_a'
terraform -chdir=binding-migration apply -var='run_id=<unique>' -var='phase=independent'
terraform -chdir=binding-migration apply -var='run_id=<unique>' -var='phase=ecs_b'
terraform -chdir=binding-migration apply -var='run_id=<unique>' -var='phase=nat'
terraform -chdir=binding-migration apply -var='run_id=<unique>' -var='phase=independent'
```

Run a no-change plan and compare all four outputs after every Apply. Stop immediately if Terraform proposes replacement of `module.eip.volcenginecc_vpc_eip.this["migration"]`, or if either identity output changes. A phase that configures no target counts as successful unbinding only when cloud readback and the `instance_type`/`instance_id` outputs are both empty.

Provider `0.0.65` does not currently pass that unbinding gate: omitting the Optional+Computed fields preserves the previous ECS binding, and a direct ECS-A to ECS-B update returns `InvalidEip.InstanceMismatch`. Keep this fixture as the reproducible release test; do not advertise migration support until the sequence above passes.

In the 2026-08-19 run, the disposable ECS creation helper also received Cloud Control `GetTask: couldn't find resource` twice. The binding test therefore used an existing disposable account test ECS for the ECS phase; the helper's VPC, Subnet, Security Group, and NAT resources were still created and cleaned by Terraform.

`release_with_instance` is explicitly `false` in both ECS migration phases so deleting a disposable ECS instance cannot intentionally release the EIP. The module does not provide general deletion protection; normal Terraform removal or Destroy can still release a module-owned EIP.

## Existing EIP and NLB composition boundaries

- Existing EIP reuse must have one owner. Passing an existing allocation ID to ECS, NAT, CLB, or NLB configuration does not make this EIP module its owner. Do not declare the same EIP in this module unless it has first been imported into this state.
- Destroying a consumer-only fixture must leave an externally owned EIP allocated. Record its allocation ID and address before and after the consumer lifecycle as evidence.
- CLB can use the EIP resource's `ClbInstance` binding. NLB is different: pass the existing allocation ID to the NLB resource's `zone_mappings.ipv_4_eip_id`; do not use a fabricated `NlbInstance` EIP binding type.
- For NLB acceptance, require a no-change plan after attachment, destroy only the NLB consumer, and verify that an externally owned EIP remains. If the EIP is owned by this module in the same composition, destroy consumers before the EIP and confirm the final EIP release.
