# terraform-volcenginecc-eip

## 1. 概述

基于 `volcenginecc` Provider 管理火山引擎 EIP 资源的 Terraform 模块。调用方负责 Provider 凭据、地域配置，以及通过 ID 传入的外部资源。

## 2. 用法

```hcl
module "eip" {
  source  = "terraform-volcenginecc-modules/eip/volcenginecc"
  version = "~> 1.0"

  # 请设置适用于当前环境的必填模块输入。
}
```

## 3. 示例

- `basic`：可独立运行的 basic 配置。
- `complete`：可独立运行的 complete 配置。
- `existing-eip-nlb`：可独立运行的 existing-eip-nlb 配置。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## 5. Provider

| 名称 | 来源 |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. 资源

| 名称 | 说明 |
|---|---|
| `volcenginecc_vpc_eip` | 模块定义的 volcenginecc_vpc_eip。 |
| `volcenginecc_vpc_eip` | 模块定义的 volcenginecc_vpc_eip。 |

## 7. 输入

| 名称 | 说明 |
|---|---|
| `name_prefix` | 模块定义的 name_prefix。 |
| `common_tags` | 模块定义的 common_tags。 |
| `eips` | 模块定义的 eips。 |
| `existing_eip_ids` | 模块定义的 existing_eip_ids。 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `allocation_ids` | 模块定义的 allocation_ids。 |
| `eip_addresses` | 模块定义的 eip_addresses。 |
| `created_allocation_ids` | 模块定义的 created_allocation_ids。 |
| `existing_allocation_ids` | 模块定义的 existing_allocation_ids。 |
| `eips` | 模块定义的 eips。 |

## 9. 注意事项

- 请通过 Provider 支持的方式配置凭据，不要将访问密钥写入模块文件。
- 执行变更前请审阅替换行为及 Provider 限制。
- apply 后请再次执行 `terraform plan`，并确认第二次 plan 无变更。
