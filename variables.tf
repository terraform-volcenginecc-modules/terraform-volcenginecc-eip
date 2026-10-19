variable "name_prefix" {
  description = "Optional prefix used when an EIP does not provide an explicit name. The map key is appended as the stable suffix."
  type        = string
  default     = null

  validation {
    condition     = var.name_prefix == null ? true : (trimspace(var.name_prefix) != "" && length(var.name_prefix) <= 128)
    error_message = "name_prefix must be null or a non-empty string no longer than 128 characters."
  }
}

variable "common_tags" {
  description = "Tags applied to every created EIP. Per-EIP tags override matching keys."
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition     = alltrue([for key in keys(var.common_tags) : trimspace(key) != ""])
    error_message = "common_tags keys must not be empty."
  }
}

variable "eips" {
  description = "EIPs created and managed by this module, keyed by a stable logical name. Optional instance_type and instance_id bind an EIP during creation."
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
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for eip in values(var.eips) : contains([1, 2, 3], eip.billing_type)])
    error_message = "billing_type must be 1 (subscription), 2 (pay by bandwidth), or 3 (pay by traffic)."
  }

  validation {
    condition     = alltrue([for eip in values(var.eips) : eip.bandwidth >= 1 && eip.bandwidth <= 500])
    error_message = "bandwidth must be between 1 and 500 Mbps."
  }

  validation {
    condition = alltrue([for eip in values(var.eips) : contains([
      "BGP", "SingleLine_BGP", "Fusion_BGP", "ChinaMobile", "ChinaTelecom", "ChinaUnicom",
      "ChinaMobile_Value", "ChinaUnicom_Value", "ChinaTelecom_Value"
    ], eip.isp)])
    error_message = "isp must be a line type supported by the Provider EIP schema."
  }

  validation {
    condition = alltrue([
      for eip in values(var.eips) : eip.instance_type == null ? true : contains([
        "Nat", "NetworkInterface", "ClbInstance", "EcsInstance", "HaVip"
      ], eip.instance_type)
    ])
    error_message = "instance_type must be Nat, NetworkInterface, ClbInstance, EcsInstance, or HaVip."
  }

  validation {
    condition = alltrue([
      for eip in values(var.eips) : eip.private_ip_address == null ? true : can(cidrhost("${eip.private_ip_address}/32", 0))
    ])
    error_message = "private_ip_address must be a valid IPv4 address when provided."
  }

  validation {
    condition = alltrue([
      for eip in values(var.eips) : eip.period_unit == null ? true : contains([1, 2], eip.period_unit)
    ])
    error_message = "period_unit must be 1 (month) or 2 (year)."
  }

  validation {
    condition = alltrue([
      for eip in values(var.eips) : eip.renew_type == null ? true : contains([1, 2, 3], eip.renew_type)
    ])
    error_message = "renew_type must be 1 (manual), 2 (automatic), or 3 (no renewal)."
  }

  validation {
    condition = alltrue([
      for eip in values(var.eips) : eip.renew_period_times == null ? true : contains([1, 2, 3, 6, 12], eip.renew_period_times)
    ])
    error_message = "renew_period_times must be 1, 2, 3, 6, or 12 months."
  }

  validation {
    condition = alltrue(flatten([
      for eip in values(var.eips) : eip.tags == null ? [] : [for key in keys(eip.tags) : trimspace(key) != ""]
    ]))
    error_message = "Per-EIP tag keys must not be empty."
  }
}

variable "existing_eip_ids" {
  description = "Existing EIP allocation IDs to read without taking ownership, keyed by stable logical names. This module never updates or releases these EIPs."
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([
      for key, id in var.existing_eip_ids : trimspace(key) != "" && trimspace(id) != ""
    ])
    error_message = "existing_eip_ids keys and allocation IDs must be non-empty strings."
  }
}
