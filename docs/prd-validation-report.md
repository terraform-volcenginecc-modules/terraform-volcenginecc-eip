# EIP PRD 场景验证报告

## 验证结论

**结论：不通过，暂不满足发布门禁。**

basic 独立 EIP、complete 的 ECS/NAT 绑定、已有 EIP 复用、计费类型、带宽、BGP 线路、ECS 释放选项、绑定目标和普通 tags 均已通过真实云验证；但显式清空 tags 后二次 plan 仍有持续差异，并且 Provider 无法完成显式解绑后迁移，因此未达到 PRD 要求的全生命周期幂等和“先解绑再释放”标准。

## 1. 验证范围

依据 `docs/terraformcc-module-registry.md` 第 7 项“管理弹性公网 IP”场景，验证以下能力：

- basic：独立创建一个 EIP；
- complete：独立 EIP、ECS 绑定 EIP、NAT Gateway 绑定 EIP；
- existing EIP：复用外部 EIP，并把统一的 allocation ID 传给下游负载均衡组合；
- 关注项：计费类型、带宽、线路类型、绑定目标、ECS 专属释放行为、tags；
- 生命周期：创建、更新、绑定、解绑/迁移、依赖顺序销毁、二次 plan 幂等。

真实云验证使用 `tests/` 下的 fixture。Provider 凭证未在用例或命令中声明，实际沿用默认凭证链 `~/.volcengine/config.json`。所有本次创建的真实云资源均使用唯一 `run_id`，验证结束后已清理。

## 2. 用例结果矩阵

| 用例 | Fixture | 主要检查 | 结果 | 判定 |
|---|---|---|---|---|
| B-01 | `tests/lifecycle` `phase=create` | 独立 EIP、pay-by-traffic、带宽、BGP、tags、地址/ID输出 | apply 成功，二次 plan `No changes` | 通过 |
| B-02 | `tests/lifecycle` `phase=update` | 带宽、名称、描述、tags 更新；增加第二个 EIP | 只发生预期更新/创建，二次 plan `No changes` | 通过 |
| B-03 | `tests/lifecycle` `phase=remove` | map key 删除及单个 EIP 释放 | 只删除目标 EIP，保留 EIP ID/地址不变 | 通过 |
| B-04 | `tests/lifecycle` `phase=clear` | tags 显式清空和回读 | 云端已清空，但二次 plan 持续提出 `tags = []` | 不通过 |
| C-01 | `tests/binding-targets` | 创建临时 VPC、Subnet、安全组、两个 ECS、NAT | VPC/NAT 创建成功；ECS 创建被 Cloud Control `GetTask` 错误阻断 | 部分通过 |
| C-02 | `tests/binding-migration` `phase=independent` | 独立 EIP 基线 | 输出正确，二次 plan `No changes` | 通过 |
| C-03 | `tests/binding-migration` `phase=ecs_a` | ECS 绑定、`release_with_instance=false` | 绑定目标正确，ID/地址不变，二次 plan `No changes` | 通过 |
| C-04 | `tests/binding-migration` 目标切换 | ECS/NAT 之间解绑迁移 | ECS→NAT 返回 `InvalidEip.InstanceMismatch`，省略字段不能显式解绑 | 不通过 |
| C-05 | `tests/binding-migration` `phase=nat` | 独立创建并直接绑定 NAT | 输出正确，二次 plan `No changes` | 通过 |
| R-01 | `tests/existing-eip` | 读取已有 EIP，不创建、不接管 | plan 仅读取 data source；destroy 为 `0 destroyed` | 通过 |
| R-02 | `examples/existing-eip-nlb` 配置检查 | NLB 使用 `zone_mappings.ipv_4_eip_id` | init/validate/静态 plan 通过，未执行真实 NLB apply | 未做真实云验证 |
| D-01 | 绑定场景清理 | 解绑、释放及依赖顺序 | 绑定 EIP 可销毁且无残留，但无法单独证明显式解绑步骤 | 不通过完整门禁 |

## 3. 判定规则

### 通过

1. 每个 apply 后的同阶段二次 plan 返回 `No changes`。
2. 创建模式产生 EIP resource；复用模式只读取 data source，不产生 EIP resource。
3. apply 输出的 EIP 地址、allocation ID、`instance_type`、`instance_id` 与云端回读一致。
4. 更新只改变预期字段，不替换 allocation ID；map key 删除只释放对应 EIP。
5. destroy 按消费者、EIP、目标网络资源的依赖顺序执行，云端查询确认资源和计费残留为空。

### 阻断

- Provider 回读与配置持续产生差异；
- 解绑/迁移无法完成，或改变 allocation ID/address；
- destroy 在消费者仍绑定时直接释放失败，或留下计费资源；
- 复用模式意外创建、接管或释放外部 EIP；
- 无法验证 CLB/NLB 所声明的绑定字段。

## 4. 验证环境与边界

- 日期：`2026-08-19`
- Region：`cn-beijing`
- Provider：`volcengine/volcenginecc 0.0.65`
- 凭证：默认凭证链，未在 Terraform 配置或执行命令中指定

验证边界：

- `release_with_instance` 仅适用于按量 ECS 绑定，不是通用删除保护；普通 Terraform destroy 仍会释放模块拥有的 EIP。
- `tests/validate.sh` 的静态计划使用假凭证和 `-refresh=false`，只用于 schema/config 检查；真实云验收必须直接使用默认凭证链。
- Provider 的 Optional+Computed 绑定字段及空 tags 回读是重点风险，必须以真实云结果决定是否达到发布门禁。

## 5. 详细验证证据

### 通过项

- B-01：独立 EIP `eip-2euj1dx50answ26wsx0cwqmeg`，地址 `124.174.93.3`；pay-by-traffic、5 Mbps、BGP、tags 输出正确；同阶段二次 plan 为 `No changes`。
- B-02：主 EIP 带宽 5→10、名称/描述/tags 更新成功，并新增 pay-by-bandwidth 的第二 EIP；二次 plan 为 `No changes`。
- B-03：删除第二个 map key 只释放第二个 EIP，主 EIP allocation ID/address 保持不变；二次 plan 为 `No changes`。
- R-01：`tests/existing-eip` 读取主 EIP，plan 没有 EIP resource 创建，输出 `ownership = external`；apply 后二次 plan 为 `No changes`；destroy 为 `0 destroyed`，云端查询确认外部 EIP 仍存在。随后才通过原 `lifecycle` state 销毁这枚本次验收创建的 managed EIP。
- C-02：绑定 fixture 独立阶段创建 EIP `eip-3isp832ej4ni84dwdlv0k2opg`，地址 `124.174.121.130`；二次 plan 为 `No changes`。
- C-03：绑定现有测试 ECS `i-yet3tpwoaowh2yr0v01n` 成功，输出 `instance_type = EcsInstance`、`release_with_instance = false`；二次 plan 为 `No changes`，allocation ID/address 未变。
- C-05：新建 EIP `eip-2qtk1v12a6mtc1s7fz739jbuf` 直接绑定临时 NAT `ngw-a9ar3pdi8mps592uash8focp` 成功，地址 `124.174.90.187`；二次 plan 为 `No changes`。
- 清理结果：绑定 EIP 销毁成功，之后销毁 NAT、Subnet、VPC；EIP allocation ID 批量查询返回 `TotalCount = 0`，无本次验收资源残留。由于 Provider 无法显式解绑，这只能证明销毁路径能够释放，不能证明“先显式解绑、再释放”的完整门禁。

### 未通过/阻断项

- B-04：tags 清空 apply 后云端 tags 为空，但下一次 plan 持续提出 `tags = []`，未达到幂等通过标准。
- C-04：从 ECS 改绑 NAT 返回 `InvalidEip.InstanceMismatch`；此前同一 Provider 的 ECS A→ECS B 迁移也有相同限制。当前 Provider 无法完成地址保持的解绑/迁移闭环。
- C-01：`tests/binding-targets` 的临时 ECS 创建两次都返回 Cloud Control `GetTask: couldn't find resource`，云端未生成 ECS；本次改用账号中已有测试 ECS 完成 ECS 绑定验证。该 Provider/ECS fixture 问题仍需单独修复。
- R-02：NLB 组合已完成静态校验和 `ipv_4_eip_id` 配置检查，本次未创建真实 NLB；PRD 的“复用已有 EIP”已由 R-01 完成。

本次不满足“全部通过”的发布门禁，主要阻断为 tags 空值回读和绑定解绑/迁移语义，不能据此发布。

## 6. 清理与残留确认

- 本次创建的四个 EIP allocation ID 批量查询结果：`TotalCount = 0`。
- 本次创建的 VPC 精确查询结果：`TotalCount = 0`。
- `tests/lifecycle`、`tests/existing-eip`、`tests/binding-migration`、`tests/binding-targets` 的 Terraform state 均为空。
- `.terraform`、`.terraform.lock.hcl`、`terraform.tfstate*` 等本地验证生成物已清理。
