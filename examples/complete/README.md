# COMPLETE EIP Example

## Overview

Runnable complete configuration for the EIP module. It configures the provider from input variables and calls the published Registry module.

## Usage

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## Resources

| Name | Description |
|---|---|
| `terraform-volcenginecc-modules/eip/volcenginecc` | Published EIP module. |

## Inputs

| Name | Description |
|---|---|
| `region` | Module-defined region. |
| `ecs_instance_id` | Module-defined ecs_instance_id. |
| `nat_gateway_id` | Module-defined nat_gateway_id. |

## Outputs

| Name | Description |
|---|---|
| `allocation_ids` | Module-defined allocation_ids. |
| `eips` | Module-defined eips. |

## Examples

This directory is the complete example.

## Notes

- Supply credentials through supported provider configuration, never in source files.
- The final plan after apply must report no changes before the configuration is accepted.
