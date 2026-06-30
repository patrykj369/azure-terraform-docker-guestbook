output "id" {
  description = "ID of the private DNS zone virtual network link"
  value       = azurerm_private_dns_zone_virtual_network_link.name.id
}

output "name" {
  description = "Name of the private DNS zone virtual network link"
  value       = azurerm_private_dns_zone_virtual_network_link.name.name
}