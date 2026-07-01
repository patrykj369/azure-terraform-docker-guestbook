resource "azurerm_container_app_environment" "main" {
  name                     = var.container_app_environment_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  infrastructure_subnet_id = var.infrastructure_subnet_id

  tags = var.common_tags
}


