variable "region" {
  description = "Volcengine region in which to allocate the EIP."
  type        = string
  default     = "cn-beijing"
}

variable "name_prefix" {
  description = "Prefix used when an EIP does not provide an explicit name."
  type        = string
}

variable "eips" {
  description = "EIPs created by this example, keyed by a stable logical name."
  type = map(object({
    billing_type          = number
    bandwidth             = optional(number, 1)
    isp                   = optional(string, "BGP")
    name                  = optional(string)
    description           = optional(string)
    project_name          = optional(string, "default")
    instance_type         = optional(string)
    instance_id           = optional(string)
    private_ip_address    = optional(string)
    direct_mode           = optional(bool)
    release_with_instance = optional(bool)
    period                = optional(number)
    period_unit           = optional(number)
    renew_type            = optional(number)
    renew_period_times    = optional(number)
    tags                  = optional(map(string))
  }))
}

variable "common_tags" {
  description = "Tags applied to every EIP created by this example."
  type        = map(string)
  default     = {}
}
