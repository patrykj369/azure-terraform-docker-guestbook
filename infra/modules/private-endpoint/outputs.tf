output "id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.main.id
}

output "name" {
  description = "Name of the private endpoint"
  value       = azurerm_private_endpoint.main.name
}

output "private_service_connection_id" {
  description = "ID of the private service connection"
  value       = azurerm_private_endpoint.main.private_service_connection[0].id
}