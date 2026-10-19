locals {
  normalized_eips = {
    for key, eip in var.eips : key => merge(eip, {
      name            = coalesce(eip.name, var.name_prefix == null ? key : "${var.name_prefix}-${key}")
      tags            = merge(var.common_tags, coalesce(eip.tags, {}))
      tags_configured = length(var.common_tags) > 0 || eip.tags != null
    })
  }
}

resource "volcenginecc_vpc_eip" "this" {
  for_each = local.normalized_eips

  billing_type          = each.value.billing_type
  bandwidth             = each.value.bandwidth
  isp                   = each.value.isp
  name                  = each.value.name
  description           = each.value.description
  project_name          = each.value.project_name
  instance_type         = each.value.instance_type
  instance_id           = each.value.instance_id
  private_ip_address    = each.value.private_ip_address
  direct_mode           = each.value.direct_mode
  release_with_instance = each.value.release_with_instance
  period                = each.value.period
  period_unit           = each.value.period_unit
  renew_type            = each.value.renew_type
  renew_period_times    = each.value.renew_period_times

  tags = each.value.tags_configured ? [
    for key in sort(keys(each.value.tags)) : {
      key   = key
      value = each.value.tags[key]
    }
  ] : null

  lifecycle {
    precondition {
      condition = (
        length(each.value.name) >= 1 &&
        length(each.value.name) <= 128 &&
        can(regex("^[\\p{L}\\p{N}][\\p{L}\\p{N}._-]*$", each.value.name))
      )
      error_message = "The generated EIP name must contain 1 to 128 supported characters and start with a letter or number."
    }

    precondition {
      condition     = each.value.billing_type != 3 || each.value.bandwidth <= 200
      error_message = "Traffic-billed EIPs (billing_type 3) support bandwidth values from 1 through 200 Mbps."
    }

    precondition {
      condition = each.value.instance_type == null ? each.value.instance_id == null : (
        each.value.instance_id == null ? false : trimspace(each.value.instance_id) != ""
      )
      error_message = "instance_type and instance_id must either both be omitted or both be provided."
    }

    precondition {
      condition = each.value.private_ip_address == null ? true : contains(
        ["EcsInstance", "NetworkInterface"],
        each.value.instance_type
      )
      error_message = "private_ip_address is supported only for EcsInstance or NetworkInterface bindings."
    }

    precondition {
      condition = (
        each.value.billing_type == 1 ||
        (each.value.period == null && each.value.period_unit == null && each.value.renew_type == null && each.value.renew_period_times == null)
      )
      error_message = "period, period_unit, renew_type, and renew_period_times are supported only when billing_type is 1."
    }

    precondition {
      condition = (
        (each.value.renew_type == 2) == (each.value.renew_period_times != null)
      )
      error_message = "renew_type 2 and renew_period_times must be configured together."
    }

    precondition {
      condition = (
        each.value.period == null ? true :
        (
          coalesce(each.value.period_unit, 1) == 1 &&
          contains([1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 24, 36, 48, 60], each.value.period)
        ) ||
        (
          each.value.period_unit == 2 &&
          contains([1, 2, 3, 4, 5], each.value.period)
        )
      )
      error_message = "period must be 1-9, 12, 24, 36, 48, or 60 months, or 1-5 years."
    }

    precondition {
      condition = (
        (
          contains([2, 3], each.value.billing_type) &&
          each.value.instance_type == "EcsInstance" &&
          each.value.release_with_instance != null
          ) || (
          !(contains([2, 3], each.value.billing_type) && each.value.instance_type == "EcsInstance") &&
          each.value.release_with_instance == null
        )
      )
      error_message = "release_with_instance must be explicitly set for a pay-as-you-go EIP bound to EcsInstance and must be omitted for every other binding. Set it to false when the EIP must survive ECS deletion."
    }

    precondition {
      condition     = each.value.direct_mode == null || each.value.instance_id != null
      error_message = "direct_mode is meaningful only when an EIP binding target is configured."
    }
  }
}

data "volcenginecc_vpc_eip" "existing" {
  for_each = var.existing_eip_ids

  id = each.value
}
