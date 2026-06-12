resource "azurerm_container_registry" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  admin_enabled       = true
  sku                 = var.sku

  tags = var.common_tags
}
