output "name" {
    description = "Name of the private DNS zone"
    value       = azurerm_private_dns_zone.name.name
}