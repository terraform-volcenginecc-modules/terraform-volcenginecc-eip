output "allocation_ids" {
  description = "Map of stable logical keys to created or explicitly referenced existing EIP allocation IDs."
  value = merge(
    { for key, eip in volcenginecc_vpc_eip.this : key => eip.allocation_id },
    { for key, eip in data.volcenginecc_vpc_eip.existing : key => eip.allocation_id },
  )

  precondition {
    condition     = length(var.eips) + length(var.existing_eip_ids) > 0
    error_message = "At least one created eips item or existing_eip_ids item must be configured."
  }

  precondition {
    condition     = length(setintersection(toset(keys(var.eips)), toset(keys(var.existing_eip_ids)))) == 0
    error_message = "eips and existing_eip_ids must use distinct logical keys."
  }
}

output "eip_addresses" {
  description = "Map of stable logical keys to created or explicitly referenced existing public IPv4 addresses."
  value = merge(
    { for key, eip in volcenginecc_vpc_eip.this : key => eip.eip_address },
    { for key, eip in data.volcenginecc_vpc_eip.existing : key => eip.eip_address },
  )
}

output "created_allocation_ids" {
  description = "Allocation IDs owned and created by this module."
  value       = { for key, eip in volcenginecc_vpc_eip.this : key => eip.allocation_id }
}

output "existing_allocation_ids" {
  description = "Existing allocation IDs read without ownership by this module."
  value       = { for key, eip in data.volcenginecc_vpc_eip.existing : key => eip.allocation_id }
}

output "eips" {
  description = "Created and existing EIP details for downstream ECS, NAT Gateway, load-balancer, and networking modules. The ownership field identifies destroy behavior."
  value = merge(
    {
      for key, eip in volcenginecc_vpc_eip.this : key => {
        ownership             = "managed"
        allocation_id         = eip.allocation_id
        address               = eip.eip_address
        name                  = eip.name
        status                = eip.status
        billing_type          = eip.billing_type
        bandwidth             = eip.bandwidth
        isp                   = eip.isp
        project_name          = eip.project_name
        instance_type         = eip.instance_type
        instance_id           = eip.instance_id
        release_with_instance = eip.release_with_instance
        business_status       = eip.business_status
        is_blocked            = eip.is_blocked
        tags = eip.tags == null ? tomap({}) : tomap({
          for tag in eip.tags : tag.key => tag.value == null ? "" : tag.value
        })
      }
    },
    {
      for key, eip in data.volcenginecc_vpc_eip.existing : key => {
        ownership             = "external"
        allocation_id         = eip.allocation_id
        address               = eip.eip_address
        name                  = eip.name
        status                = eip.status
        billing_type          = eip.billing_type
        bandwidth             = eip.bandwidth
        isp                   = eip.isp
        project_name          = eip.project_name
        instance_type         = eip.instance_type
        instance_id           = eip.instance_id
        release_with_instance = eip.release_with_instance
        business_status       = eip.business_status
        is_blocked            = eip.is_blocked
        tags = eip.tags == null ? tomap({}) : tomap({
          for tag in eip.tags : tag.key => tag.value == null ? "" : tag.value
        })
      }
    },
  )
}
