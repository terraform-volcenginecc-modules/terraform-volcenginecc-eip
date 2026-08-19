variable "region" {
  description = "Region used for real-cloud acceptance."
  type        = string
  default     = "cn-beijing"
}

variable "run_id" {
  description = "Unique suffix used to identify acceptance resources."
  type        = string
}

variable "phase" {
  description = "Lifecycle phase: create, update, remove, or clear."
  type        = string
  validation {
    condition     = contains(["create", "update", "remove", "clear"], var.phase)
    error_message = "phase must be create, update, remove, or clear."
  }
}
