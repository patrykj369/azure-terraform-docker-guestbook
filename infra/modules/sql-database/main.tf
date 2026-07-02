resource "azurerm_mssql_server" "main" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.admin_login
  administrator_login_password  = var.admin_password
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.common_tags
}

resource "azurerm_mssql_database" "main" {
  name                 = var.database_name
  server_id            = azurerm_mssql_server.main.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  sku_name             = var.sku_name
  storage_account_type = "Local"

  tags = var.common_tags
}
