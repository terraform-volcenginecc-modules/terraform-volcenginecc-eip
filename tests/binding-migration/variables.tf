variable "region" {
  description = "Region used for real-cloud binding acceptance."
  type        = string
  default     = "cn-beijing"
}

variable "run_id" {
  description = "Unique suffix used to identify acceptance resources."
  type        = string
}

variable "phase" {
  description = "Binding phase: independent, ecs_a, ecs_b, or nat."
  type        = string

  validation {
    condition     = contains(["independent", "ecs_a", "ecs_b", "nat"], var.phase)
    error_message = "phase must be independent, ecs_a, ecs_b, or nat."
  }
}

variable "ecs_instance_a_id" {
  description = "First disposable ECS instance ID used by the ecs_a phase."
  type        = string

  validation {
    condition     = trimspace(var.ecs_instance_a_id) != ""
    error_message = "ecs_instance_a_id must not be empty."
  }
}

variable "ecs_instance_b_id" {
  description = "Second disposable ECS instance ID used by the ecs_b phase."
  type        = string

  validation {
    condition     = trimspace(var.ecs_instance_b_id) != ""
    error_message = "ecs_instance_b_id must not be empty."
  }
}

variable "nat_gateway_id" {
  description = "Disposable public NAT Gateway ID used by the nat phase."
  type        = string

  validation {
    condition     = trimspace(var.nat_gateway_id) != ""
    error_message = "nat_gateway_id must not be empty."
  }
}
