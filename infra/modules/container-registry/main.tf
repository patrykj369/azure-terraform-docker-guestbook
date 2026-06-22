resource "azurerm_container_registry" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  admin_enabled       = false  # Use managed identity and RBAC instead of admin credentials
  sku                 = var.sku

  tags = var.common_tags
}

# Grant AcrPull role to application managed identity
# This allows the application to pull images from the registry
resource "azurerm_role_assignment" "app_acr_pull" {
  count = var.app_managed_identity_principal_id != "" ? 1 : 0

  scope              = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id       = var.app_managed_identity_principal_id
}

