output "allocation_ids" {
  description = "Allocation IDs created by the lifecycle fixture."
  value       = module.eips.allocation_ids
}

output "eip_addresses" {
  description = "Public IPv4 addresses created by the lifecycle fixture."
  value       = module.eips.eip_addresses
}

output "eips" {
  description = "Cloud-read EIP details used by the acceptance record."
  value       = module.eips.eips
}
