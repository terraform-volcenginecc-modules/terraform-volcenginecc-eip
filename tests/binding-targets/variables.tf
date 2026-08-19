variable "region" {
  description = "Region used by the real-cloud binding-target fixture."
  type        = string
  default     = "cn-beijing"

  validation {
    condition     = trimspace(var.region) != ""
    error_message = "region must be a non-empty region ID."
  }
}

variable "run_id" {
  description = "Unique suffix used in the names of all fixture resources."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9._-]{0,31}$", var.run_id))
    error_message = "run_id must be 1-32 characters, start with a letter or number, and contain only letters, numbers, periods, underscores, or hyphens."
  }
}

variable "zone_id" {
  description = "Availability zone in which to create the subnet, ECS instances, and NAT Gateway."
  type        = string

  validation {
    condition     = trimspace(var.zone_id) != ""
    error_message = "zone_id must be a non-empty availability-zone ID."
  }
}

variable "image_id" {
  description = "Image ID used by both temporary ECS binding targets."
  type        = string

  validation {
    condition     = trimspace(var.image_id) != ""
    error_message = "image_id must be a non-empty image ID."
  }
}

variable "instance_type" {
  description = "Small PostPaid ECS instance type available in the selected zone."
  type        = string

  validation {
    condition     = trimspace(var.instance_type) != ""
    error_message = "instance_type must be a non-empty ECS instance type."
  }
}

variable "ecs_password" {
  description = "Temporary password for both disposable ECS targets. Supply it only through a local environment variable or uncommitted tfvars file."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.ecs_password) >= 8
    error_message = "ecs_password must contain at least 8 characters."
  }
}
