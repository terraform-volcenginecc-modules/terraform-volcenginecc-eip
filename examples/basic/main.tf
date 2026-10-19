provider "volcenginecc" {
  region = var.region
}

module "eip" {
  source  = "terraform-volcenginecc-modules/eip/volcenginecc"
  version = "~> 1.0"

  name_prefix = var.name_prefix
  eips        = var.eips
  common_tags = var.common_tags
}
