output "allocation_id" {
  description = "Referenced external EIP allocation ID."
  value       = module.eip.allocation_ids["external"]
}

output "eip_address" {
  description = "Referenced external EIP public address."
  value       = module.eip.eip_addresses["external"]
}

output "ownership" {
  description = "Ownership marker proving this fixture does not manage the EIP lifecycle."
  value       = module.eip.eips["external"].ownership
}
