output "source_ecs_instance_id" {
  description = "ID of the first ECS target used as the source of an EIP migration."
  value       = volcenginecc_ecs_instance.fixture["source"].instance_id
}

output "destination_ecs_instance_id" {
  description = "ID of the second ECS target used as the destination of an EIP migration."
  value       = volcenginecc_ecs_instance.fixture["destination"].instance_id
}

output "nat_gateway_id" {
  description = "ID of the public NAT Gateway binding target."
  value       = volcenginecc_natgateway_ngw.fixture.nat_gateway_id
}
