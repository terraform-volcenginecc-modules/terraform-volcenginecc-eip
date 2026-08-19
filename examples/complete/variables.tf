variable "region" {
  description = "Volcengine region in which to allocate EIPs."
  type        = string
  default     = "cn-beijing"
}

variable "ecs_instance_id" {
  description = "ID of an existing ECS instance to which the example binds its ecs EIP. The instance remains externally owned."
  type        = string

  validation {
    condition     = trimspace(var.ecs_instance_id) != ""
    error_message = "ecs_instance_id must not be empty."
  }
}

variable "nat_gateway_id" {
  description = "ID of an existing internet NAT Gateway to which the example binds its nat EIP. The gateway remains externally owned."
  type        = string

  validation {
    condition     = trimspace(var.nat_gateway_id) != ""
    error_message = "nat_gateway_id must not be empty."
  }
}
