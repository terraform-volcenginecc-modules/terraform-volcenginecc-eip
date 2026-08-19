#!/usr/bin/env bash

set -euo pipefail

test_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
module_root="$(cd "$test_root/.." && pwd)"
validation_root="$(mktemp -d)"
validation_module_root="$validation_root/module"

cleanup() {
  if [[ -n "$validation_root" && -d "$validation_root" ]]; then
    rm -rf -- "$validation_root"
  fi
}
trap cleanup EXIT

terraform -chdir="$test_root" fmt -check -recursive

mkdir -p "$validation_module_root"
tar --exclude=".terraform" --exclude=".terraform.lock.hcl" --exclude="*.tfplan" --exclude="*.tfstate" --exclude="*.tfstate.*" -cf - -C "$module_root" . |
  tar -xf - -C "$validation_module_root"

target_dir="$validation_module_root/tests/lifecycle"
terraform -chdir="$target_dir" init -backend=false -input=false >/dev/null
terraform -chdir="$target_dir" validate

for phase in create update remove clear; do
  env VOLCENGINE_ACCESS_KEY=static-validation VOLCENGINE_SECRET_KEY=static-validation VOLCENGINE_REGION=cn-beijing \
    terraform -chdir="$target_dir" plan -refresh=false -input=false -lock=false \
    -var="run_id=static-validation" -var="phase=$phase" >/dev/null
done

binding_target_dir="$validation_module_root/tests/binding-migration"
terraform -chdir="$binding_target_dir" init -backend=false -input=false >/dev/null
terraform -chdir="$binding_target_dir" validate

for phase in independent ecs_a ecs_b nat; do
  env VOLCENGINE_ACCESS_KEY=static-validation VOLCENGINE_SECRET_KEY=static-validation VOLCENGINE_REGION=cn-beijing \
    terraform -chdir="$binding_target_dir" plan -refresh=false -input=false -lock=false \
    -var="run_id=static-validation" -var="phase=$phase" \
    -var="ecs_instance_a_id=i-static-a" -var="ecs_instance_b_id=i-static-b" \
    -var="nat_gateway_id=ngw-static" >/dev/null
done

targets_dir="$validation_module_root/tests/binding-targets"
terraform -chdir="$targets_dir" init -backend=false -input=false >/dev/null
terraform -chdir="$targets_dir" validate
env VOLCENGINE_ACCESS_KEY=static-validation VOLCENGINE_SECRET_KEY=static-validation VOLCENGINE_REGION=cn-beijing \
  terraform -chdir="$targets_dir" plan -refresh=false -input=false -lock=false \
  -var="run_id=static-validation" -var="zone_id=cn-beijing-a" \
  -var="image_id=image-static" -var="instance_type=ecs.static" \
  -var="ecs_password=StaticValidation1!" >/dev/null

existing_dir="$validation_module_root/tests/existing-eip"
terraform -chdir="$existing_dir" init -backend=false -input=false >/dev/null
terraform -chdir="$existing_dir" validate

echo "Real-cloud lifecycle, binding-target, binding-migration, and existing-EIP fixtures passed static validation."
