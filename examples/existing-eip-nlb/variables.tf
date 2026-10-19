variable "region" {
  description = "Volcengine region in which to create the NLB."
  type        = string
  default     = "cn-beijing"
}

variable "vpc_id" {
  description = "ID of the existing VPC for the NLB."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs associated with the NLB."
  type        = set(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "security_group_ids must contain at least one security group ID."
  }
}

variable "zone_mappings" {
  description = "NLB availability zones and existing subnets. The same EIP is passed through the Provider NLB zone mapping."
  type = list(object({
    zone_id   = string
    subnet_id = string
  }))

  validation {
    condition     = length(var.zone_mappings) == 1
    error_message = "This single-EIP example requires exactly one NLB zone mapping."
  }
}

variable "existing_eip_id" {
  description = "Optional externally owned EIP allocation ID. When null, the EIP module creates and owns an address for the NLB."
  type        = string
  default     = null

  validation {
    condition     = var.existing_eip_id == null ? true : trimspace(var.existing_eip_id) != ""
    error_message = "existing_eip_id must be null or a non-empty allocation ID."
  }
}

variable "load_balancer_name" {
  description = "Name of the NLB instance."
  type        = string
  default     = "eip-nlb-example"
}

variable "project_name" {
  description = "Project assigned to the NLB and newly created EIP."
  type        = string
  default     = "default"
}
