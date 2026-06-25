resource "azurerm_key_vault" "main" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  enable_rbac_authorization   = true # Use RBAC instead of access policies

  tags = var.common_tags
}

# Grant Key Vault Secrets User role to application managed identity
# This allows the application to read secrets at runtime
resource "azurerm_role_assignment" "app_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.app_managed_identity_principal_id

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "key_vault_admins" {
  for_each = toset(var.key_vault_admin_principal_ids)

  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

data "azurerm_client_config" "current" {}

