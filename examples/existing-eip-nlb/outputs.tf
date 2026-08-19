output "allocation_id" {
  description = "EIP allocation ID attached to the NLB, whether managed here or supplied externally."
  value       = module.eip.allocation_ids["nlb"]
}

output "eip_address" {
  description = "Public IPv4 address attached to the NLB."
  value       = module.eip.eip_addresses["nlb"]
}

output "eip_is_externally_owned" {
  description = "True when this example reads and reuses an existing EIP instead of creating it."
  value       = var.existing_eip_id != null
}

output "nlb_id" {
  description = "ID of the NLB consuming the EIP."
  value       = volcenginecc_clb_nlb.this.load_balancer_id
}
