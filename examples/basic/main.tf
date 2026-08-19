provider "volcenginecc" {
  region = var.region
}

module "eip" {
  source  = "volcengine/eip/volcenginecc"
  version = "~> 1.0"

  name_prefix = "example"
  eips = {
    primary = {
      billing_type = 3
      bandwidth    = 5
    }
  }

  common_tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}
