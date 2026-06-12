output "id" {
  description = "ID of the container registry"
  value       = azurerm_container_registry.main.id
}

output "login_server" {
  description = "Login server of the container registry"
  value       = azurerm_container_registry.main.login_server
}

output "admin_username" {
  description = "Admin username of the container registry"
  value       = azurerm_container_registry.main.admin_username
}

output "admin_password" {
  description = "Admin password of the container registry"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}
