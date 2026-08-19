provider "volcenginecc" {
  region = var.region
}

locals {
  binding = {
    independent = {
      instance_type = null
      instance_id   = null
    }
    ecs_a = {
      instance_type = "EcsInstance"
      instance_id   = var.ecs_instance_a_id
    }
    ecs_b = {
      instance_type = "EcsInstance"
      instance_id   = var.ecs_instance_b_id
    }
    nat = {
      instance_type = "Nat"
      instance_id   = var.nat_gateway_id
    }
  }[var.phase]
}

module "eip" {
  source = "../.."

  name_prefix = "tf-eip-binding-${var.run_id}"
  eips = {
    migration = {
      billing_type          = 3
      bandwidth             = 5
      description           = "Disposable EIP binding and migration acceptance"
      instance_type         = local.binding.instance_type
      instance_id           = local.binding.instance_id
      release_with_instance = startswith(var.phase, "ecs_") ? false : null
      tags = {
        Acceptance = "binding-migration"
      }
    }
  }

  common_tags = {
    ManagedBy = "Terraform"
    TestRun   = var.run_id
  }
}
