variable "region" {
  description = "Region containing the externally owned EIP."
  type        = string
  default     = "cn-beijing"
}

variable "existing_eip_id" {
  description = "Allocation ID of an EIP created outside this fixture."
  type        = string

  validation {
    condition     = trimspace(var.existing_eip_id) != ""
    error_message = "existing_eip_id must be a non-empty allocation ID."
  }
}
