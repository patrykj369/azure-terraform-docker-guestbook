resource "azurerm_private_dns_zone" "name" {
  name                = var.name
  resource_group_name = var.resource_group_name
}