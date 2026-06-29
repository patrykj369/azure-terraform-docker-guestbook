output "id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}
