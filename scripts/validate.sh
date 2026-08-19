#!/usr/bin/env bash

set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
validation_dir="$(mktemp -d)"
validation_module_dir="$validation_dir/module"
provider_version="${EIP_PROVIDER_VERSION:-latest}"

cleanup() {
  if [[ -n "$validation_dir" && -d "$validation_dir" ]]; then
    rm -rf -- "$validation_dir"
  fi
}
trap cleanup EXIT

terraform -chdir="$module_dir" fmt -check -recursive

mkdir -p "$validation_module_dir"
tar --exclude=".terraform" --exclude=".terraform.lock.hcl" --exclude="*.tfplan" --exclude="*.tfstate" --exclude="*.tfstate.*" -cf - -C "$module_dir" . |
  tar -xf - -C "$validation_module_dir"

if [[ "$provider_version" != "latest" ]]; then
  PROVIDER_VERSION="$provider_version" perl -0pi -e \
    's#version\s*=\s*">= 0\.0\.60"#version = "=$ENV{PROVIDER_VERSION}"#g' \
    "$validation_module_dir/versions.tf"
fi

echo "Validating Provider version: $provider_version"
terraform -chdir="$validation_module_dir" init -backend=false -input=false >/dev/null
terraform -chdir="$validation_module_dir" validate

provider_env=(
  "VOLCENGINE_ACCESS_KEY=static-validation"
  "VOLCENGINE_SECRET_KEY=static-validation"
  "VOLCENGINE_REGION=cn-beijing"
)
valid_eips='eips={primary={billing_type=3,bandwidth=5}}'

env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false -input=false -lock=false -var="$valid_eips" >/dev/null

expect_plan_failure() {
  local description="$1"
  shift
  if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
    -refresh=false -input=false -lock=false "$@" >/dev/null 2>&1; then
    echo "$description unexpectedly passed validation." >&2
    exit 1
  fi
}

expect_plan_failure "No created or existing EIP" -var='eips={}' -var='existing_eip_ids={}'
expect_plan_failure "An unsupported billing type" -var='eips={primary={billing_type=4}}'
expect_plan_failure "Traffic billing above 200 Mbps" -var='eips={primary={billing_type=3,bandwidth=201}}'
expect_plan_failure "A binding missing instance_id" -var='eips={primary={billing_type=3,instance_type="EcsInstance"}}'
expect_plan_failure "A binding missing instance_type" -var='eips={primary={billing_type=3,instance_id="i-static"}}'
expect_plan_failure "A private IP on a NAT binding" -var='eips={primary={billing_type=3,instance_type="Nat",instance_id="ngw-static",private_ip_address="10.0.0.2"}}'
expect_plan_failure "Subscription fields on pay-as-you-go EIP" -var='eips={primary={billing_type=3,period=1,period_unit=1}}'
expect_plan_failure "Automatic renewal without a renewal period" -var='eips={primary={billing_type=1,renew_type=2}}'
expect_plan_failure "Renewal period without automatic renewal" -var='eips={primary={billing_type=1,renew_type=1,renew_period_times=1}}'
expect_plan_failure "An invalid generated EIP name" -var='eips={"http://invalid"={billing_type=3}}'
expect_plan_failure "Release with a NAT instance" -var='eips={primary={billing_type=3,instance_type="Nat",instance_id="ngw-static",release_with_instance=true}}'
expect_plan_failure "Release flag on a subscription EIP" -var='eips={primary={billing_type=1,instance_type="EcsInstance",instance_id="i-static",release_with_instance=false}}'
expect_plan_failure "Pay-as-you-go ECS binding without an explicit release decision" -var='eips={primary={billing_type=3,instance_type="EcsInstance",instance_id="i-static"}}'
expect_plan_failure "An empty common tag key" -var="$valid_eips" -var='common_tags={""="invalid"}'

for example in basic complete existing-eip-nlb; do
  echo "Validating example: $example"
  target_dir="$validation_dir/$example"
  cp -R "$module_dir/examples/$example" "$target_dir"
  MODULE_DIR="$validation_module_dir" perl -0pi -e \
    's#source\s*=\s*"volcengine/eip/volcenginecc"#source = "$ENV{MODULE_DIR}"#g; s#^\s*version\s*=\s*"~> 1\.0"\s*\n##m' \
    "$target_dir/main.tf"
  grep -Fq "source = \"$validation_module_dir\"" "$target_dir/main.tf"
  terraform -chdir="$target_dir" init -backend=false -input=false >/dev/null
  terraform -chdir="$target_dir" validate
  example_args=()
  case "$example" in
    complete)
      example_args+=(
        -var="ecs_instance_id=i-static-validation"
        -var="nat_gateway_id=ngw-static-validation"
      )
      ;;
    existing-eip-nlb)
      example_args+=(
        -var="vpc_id=vpc-static-validation"
        -var='security_group_ids=["sg-static-validation"]'
        -var='zone_mappings=[{zone_id="cn-beijing-a",subnet_id="subnet-static-validation"}]'
      )
      ;;
  esac

  if ((${#example_args[@]} == 0)); then
    env "${provider_env[@]}" terraform -chdir="$target_dir" plan \
      -refresh=false -input=false -lock=false >/dev/null
  else
    env "${provider_env[@]}" terraform -chdir="$target_dir" plan \
      -refresh=false -input=false -lock=false "${example_args[@]}" >/dev/null
  fi
done

if grep -R -n -E '(access_key|secret_key)[[:space:]]*=' "$module_dir" --include='*.tf' --exclude-dir='.terraform'; then
  echo "Static credentials must not be committed." >&2
  exit 1
fi

echo "Static validation passed for the root module and all examples."
