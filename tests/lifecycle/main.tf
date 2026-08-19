provider "volcenginecc" {
  region = var.region
}

locals {
  uses_updated_fields = contains(["update", "remove", "clear"], var.phase)
  clears_tags         = var.phase == "clear"
}

module "eips" {
  source = "../.."

  name_prefix = "tf-eip-${var.run_id}"
  eips = merge(
    {
      primary = {
        billing_type = 3
        bandwidth    = local.uses_updated_fields ? 10 : 5
        name         = local.uses_updated_fields ? "tf-eip-${var.run_id}-primary-updated" : "tf-eip-${var.run_id}-primary"
        description  = local.uses_updated_fields ? "Updated acceptance EIP" : "Initial acceptance EIP"
        tags         = local.clears_tags ? {} : { Phase = local.uses_updated_fields ? "update" : "create" }
      }
    },
    var.phase == "update" ? {
      secondary = {
        billing_type = 2
        bandwidth    = 5
        description  = "Added during update"
      }
    } : {}
  )

  common_tags = local.clears_tags ? {} : {
    ManagedBy = "Terraform"
    TestRun   = var.run_id
  }
}
