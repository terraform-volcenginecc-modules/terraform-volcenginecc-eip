provider "volcenginecc" {
  region = var.region
}

module "eips" {
  source  = "volcengine/eip/volcenginecc"
  version = "~> 1.0"

  name_prefix = "application"
  eips = {
    reserved = {
      billing_type = 3
      bandwidth    = 10
      description  = "Independent EIP reserved for later composition"
      tags         = { Purpose = "portable-address" }
    }
    ecs = {
      billing_type          = 3
      bandwidth             = 20
      instance_type         = "EcsInstance"
      instance_id           = var.ecs_instance_id
      release_with_instance = false
      tags                  = { Purpose = "public-entry" }
    }
    nat = {
      billing_type  = 2
      bandwidth     = 50
      instance_type = "Nat"
      instance_id   = var.nat_gateway_id
      tags          = { Purpose = "fixed-egress" }
    }
  }

  common_tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
