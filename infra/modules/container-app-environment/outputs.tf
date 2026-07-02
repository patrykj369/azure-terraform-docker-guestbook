output "environment_id" {
  description = "ID of the container app environment"
  value       = azurerm_container_app_environment.main.id
}

output "infrastructure_subnet_id" {
  description = "ID of the subnet used for the container app environment"
  value       = azurerm_container_app_environment.main.infrastructure_subnet_id
}