# terraform-volcenginecc-eip

## 1. Overview

Terraform module for managing Volcengine EIP resources with the `volcenginecc` provider. The caller owns provider authentication, region configuration, and external resources passed by ID.

## 2. Usage

```hcl
module "eip" {
  source  = "terraform-volcenginecc-modules/eip/volcenginecc"
  version = "~> 1.0"

  # Set the required module inputs for your environment.
}
```

## 3. Examples

- `basic`: independently runnable basic configuration.
- `complete`: independently runnable complete configuration.
- `existing-eip-nlb`: independently runnable existing-eip-nlb configuration.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## 5. Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. Resources

| Name | Description |
|---|---|
| `volcenginecc_vpc_eip` | Module-defined volcenginecc_vpc_eip. |
| `volcenginecc_vpc_eip` | Module-defined volcenginecc_vpc_eip. |

## 7. Inputs

| Name | Description |
|---|---|
| `name_prefix` | Module-defined name_prefix. |
| `common_tags` | Module-defined common_tags. |
| `eips` | Module-defined eips. |
| `existing_eip_ids` | Module-defined existing_eip_ids. |

## 8. Outputs

| Name | Description |
|---|---|
| `allocation_ids` | Module-defined allocation_ids. |
| `eip_addresses` | Module-defined eip_addresses. |
| `created_allocation_ids` | Module-defined created_allocation_ids. |
| `existing_allocation_ids` | Module-defined existing_allocation_ids. |
| `eips` | Module-defined eips. |

## 9. Notes

- Configure credentials using supported provider mechanisms; do not put access keys in module files.
- Review replacement behavior and provider constraints before applying changes.
- Run `terraform plan` after apply and confirm that the second plan has no changes.
