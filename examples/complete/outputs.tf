output "allocation_ids" {
  description = "Created EIP allocation IDs for the independent, ECS-bound, and NAT-bound addresses."
  value       = module.eips.allocation_ids
}

output "eips" {
  description = "Created EIP details."
  value       = module.eips.eips
}
