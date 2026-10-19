# EXISTING EIP NLB EIP Example

## Overview

Runnable existing-eip-nlb configuration for the EIP module. It configures the provider from input variables and calls the published Registry module.

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
| `vpc_id` | Module-defined vpc_id. |
| `security_group_ids` | Module-defined security_group_ids. |
| `zone_mappings` | Module-defined zone_mappings. |
| `existing_eip_id` | Module-defined existing_eip_id. |
| `load_balancer_name` | Module-defined load_balancer_name. |
| `project_name` | Module-defined project_name. |

## Outputs

| Name | Description |
|---|---|
| `allocation_id` | Module-defined allocation_id. |
| `eip_address` | Module-defined eip_address. |
| `eip_is_externally_owned` | Module-defined eip_is_externally_owned. |
| `nlb_id` | Module-defined nlb_id. |

## Examples

This directory is the existing-eip-nlb example.

## Notes

- Supply credentials through supported provider configuration, never in source files.
- The final plan after apply must report no changes before the configuration is accepted.
