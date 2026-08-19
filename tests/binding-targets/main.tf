provider "volcenginecc" {
  region = var.region
}

locals {
  name_prefix = "tf-eip-target-${var.run_id}"
}

resource "volcenginecc_vpc_vpc" "fixture" {
  vpc_name   = local.name_prefix
  cidr_block = "10.94.0.0/16"
}

resource "volcenginecc_vpc_subnet" "fixture" {
  vpc_id      = volcenginecc_vpc_vpc.fixture.vpc_id
  cidr_block  = "10.94.1.0/24"
  zone_id     = var.zone_id
  subnet_name = local.name_prefix
}

resource "volcenginecc_vpc_security_group" "fixture" {
  vpc_id              = volcenginecc_vpc_vpc.fixture.vpc_id
  security_group_name = local.name_prefix
  description         = "Temporary EIP binding targets ${var.run_id}"
}

resource "volcenginecc_ecs_instance" "fixture" {
  for_each = toset(["source", "destination"])

  instance_name        = "${local.name_prefix}-${each.key}"
  instance_charge_type = "PostPaid"
  instance_type        = var.instance_type
  zone_id              = var.zone_id
  deletion_protection  = false
  password             = var.ecs_password

  image = {
    image_id                      = var.image_id
    security_enhancement_strategy = "InActive"
  }

  primary_network_interface = {
    security_group_ids = [volcenginecc_vpc_security_group.fixture.security_group_id]
    subnet_id          = volcenginecc_vpc_subnet.fixture.subnet_id
  }

  system_volume = {
    delete_with_instance = true
    size                 = 20
    volume_type          = "ESSD_PL0"
  }
}

resource "volcenginecc_natgateway_ngw" "fixture" {
  vpc_id           = volcenginecc_vpc_vpc.fixture.vpc_id
  subnet_id        = volcenginecc_vpc_subnet.fixture.subnet_id
  nat_gateway_name = local.name_prefix
  billing_type     = 2
  network_type     = "internet"
  spec             = "Small"
  description      = "Temporary EIP binding target ${var.run_id}"
}
