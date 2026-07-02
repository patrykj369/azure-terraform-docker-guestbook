output "id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.main.id
}

output "name" {
  description = "Name of the private endpoint"
  value       = azurerm_private_endpoint.main.name
}