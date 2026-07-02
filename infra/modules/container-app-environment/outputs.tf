output "environment_id" {
  description = "ID of the container app environment"
  value       = var.container_app_environment_name
}

output "infrastructure_subnet_id" {
  description = "ID of the subnet used for the container app environment"
  value       = var.infrastructure_subnet_id
}