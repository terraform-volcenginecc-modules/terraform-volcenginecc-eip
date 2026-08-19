output "allocation_id" {
  description = "Allocation ID of the example EIP."
  value       = module.eip.allocation_ids["primary"]
}

output "eip_address" {
  description = "Allocated public IPv4 address."
  value       = module.eip.eip_addresses["primary"]
}
