output "allocation_id" {
  description = "Allocation ID that must remain unchanged through every binding phase."
  value       = module.eip.allocation_ids["migration"]
}

output "eip_address" {
  description = "Public IPv4 address that must remain unchanged through every binding phase."
  value       = module.eip.eip_addresses["migration"]
}

output "instance_type" {
  description = "Binding type read back by the Provider."
  value       = module.eip.eips["migration"].instance_type
}

output "instance_id" {
  description = "Binding target ID read back by the Provider."
  value       = module.eip.eips["migration"].instance_id
}
