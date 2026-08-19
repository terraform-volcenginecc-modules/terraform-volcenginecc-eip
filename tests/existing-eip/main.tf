provider "volcenginecc" {
  region = var.region
}

module "eip" {
  source = "../.."

  existing_eip_ids = {
    external = var.existing_eip_id
  }
}
