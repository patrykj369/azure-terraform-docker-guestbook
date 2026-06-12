output "id" {
  description = "ID of the container app"
  value       = azurerm_container_app.main.id
}

output "fqdn" {
  description = "FQDN of the container app"
  value       = azurerm_container_app.main.ingress[0].fqdn
}

output "environment_id" {
  description = "ID of the container app environment"
  value       = azurerm_container_app_environment.main.id
}
