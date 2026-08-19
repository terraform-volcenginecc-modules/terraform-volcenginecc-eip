provider "volcenginecc" {
  region = var.region
}

module "eip" {
  source  = "volcengine/eip/volcenginecc"
  version = "~> 1.0"

  eips = var.existing_eip_id == null ? {
    nlb = {
      billing_type = 3
      bandwidth    = 10
      description  = "Public address managed with the NLB composition"
      tags         = { Purpose = "nlb-public-entry" }
    }
  } : {}

  existing_eip_ids = var.existing_eip_id == null ? {} : {
    nlb = var.existing_eip_id
  }

  name_prefix = "nlb"
  common_tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}

resource "volcenginecc_clb_nlb" "this" {
  ipv_4_network_type = "internet"
  ip_address_version = "ipv4"
  security_group_ids = var.security_group_ids
  vpc_id             = var.vpc_id
  load_balancer_name = var.load_balancer_name
  project_name       = var.project_name

  zone_mappings = [
    for mapping in var.zone_mappings : {
      zone_id      = mapping.zone_id
      subnet_id    = mapping.subnet_id
      ipv_4_eip_id = module.eip.allocation_ids["nlb"]
    }
  ]

  tags = [
    {
      key   = "ManagedBy"
      value = "Terraform"
    }
  ]
}
