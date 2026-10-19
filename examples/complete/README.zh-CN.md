# COMPLETE EIP 示例

## 概述

EIP 模块的可运行 complete 配置。它从输入变量设置 Provider，并调用已发布的 Registry 模块。

## 用法

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## 依赖要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## Providers

| 名称 | 来源 |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 资源

| 名称 | 说明 |
|---|---|
| `terraform-volcenginecc-modules/eip/volcenginecc` | 已发布的 EIP 模块。 |

## 输入

| 名称 | 说明 |
|---|---|
| `region` | 模块定义的 region。 |
| `ecs_instance_id` | 模块定义的 ecs_instance_id。 |
| `nat_gateway_id` | 模块定义的 nat_gateway_id。 |

## 输出

| 名称 | 说明 |
|---|---|
| `allocation_ids` | 模块定义的 allocation_ids。 |
| `eips` | 模块定义的 eips。 |

## 示例

本目录即为 complete 示例。

## 说明

- 请通过 Provider 支持的配置提供凭据，绝不应写入源文件。
- apply 后的最终 plan 必须报告无变更，才能接受该配置。
