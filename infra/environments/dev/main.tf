locals {
  environment = "dev"
  project     = "guestbook"
  location    = var.location

  common_tags = {
    environment = local.environment
    project     = local.project
    terraform   = true
    created_at  = timestamp()
  }
}

module "resource_group" {
  source = "../../modules/resource-group"

  name        = var.resource_group_name
  location    = var.location
  environment = local.environment
  project     = local.project
  common_tags = local.common_tags
}

module "managed_identity" {
  source = "../../modules/managed-identity"

  name                = "mid-${local.project}-${local.environment}"
  resource_group_name = module.resource_group.name
  location            = var.location
  environment         = local.environment
  project             = local.project
  common_tags         = local.common_tags
}

module "virtual_network" {
  source = "../../modules/virtual-network"

  name                = var.virtual_network_name
  resource_group_name = module.resource_group.name
  location            = var.location
  address_space       = var.virtual_network_address_space
  environment         = local.environment
  common_tags         = local.common_tags
}

module "subnet_container_apps_environment" {
  source = "../../modules/subnet"

  name                 = "snet-container-apps-${local.environment}"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.1.0/26"]

  delegation = {
    name         = "delegation-container-apps-${local.environment}"
    service_name = "Microsoft.App/environments"
    actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  }
}

module "subnet_private_endpoint" {
  source = "../../modules/subnet"

  name                 = "snet-private-endpoint-${local.environment}"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.2.0/27"]
}

module "private_dns_zone_sql" {
  source = "../../modules/private-dns-zone"

  name                = "privatelink.database.windows.net"
  resource_group_name = module.resource_group.name
}

module "private_dns_zone_sql_link" {
  source = "../../modules/private-dns-zone-virtual-network-link"

  name                  = "link-${local.project}-${local.environment}-sql"
  resource_group_name   = module.resource_group.name
  private_dns_zone_name = module.private_dns_zone_sql.name
  virtual_network_id    = module.virtual_network.id
}

module "private_endpoint_sql" {
  source = "../../modules/private-endpoint"

  name                = "pe-${local.project}-${local.environment}-sql"
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.subnet_private_endpoint.id

  private_service_connection = {
    name                           = "psc-${local.project}-${local.environment}-sql"
    private_connection_resource_id = module.sql_database.server_id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group = [
    {
      name                 = "pdzconfig-${local.project}-${local.environment}-sql"
      private_dns_zone_ids = [module.private_dns_zone_sql.id]
    }
  ]

}

module "container_registry" {
  source = "../../modules/container-registry"

  name                              = var.container_registry_name
  resource_group_name               = module.resource_group.name
  location                          = var.location
  sku                               = var.acr_sku
  environment                       = local.environment
  project                           = local.project
  common_tags                       = local.common_tags
  app_managed_identity_principal_id = module.managed_identity.principal_id
}

module "sql_database" {
  source = "../../modules/sql-database"

  server_name                   = var.sql_server_name
  database_name                 = var.sql_database_name
  resource_group_name           = module.resource_group.name
  location                      = var.location
  public_network_access_enabled = var.sql_public_network_access_enabled
  admin_login                   = var.sql_admin_login
  admin_password                = var.sql_admin_password
  sku_name                      = var.sql_sku_name
  environment                   = local.environment
  project                       = local.project
  common_tags                   = local.common_tags
}

module "key_vault" {
  source = "../../modules/key-vault"

  name                              = var.key_vault_name
  resource_group_name               = module.resource_group.name
  location                          = var.location
  tenant_id                         = data.azurerm_client_config.current.tenant_id
  environment                       = local.environment
  project                           = local.project
  common_tags                       = local.common_tags
  app_managed_identity_principal_id = module.managed_identity.principal_id
  app_managed_identity_name         = module.managed_identity.id

  key_vault_admin_principal_ids = var.key_vault_admin_principal_ids
}

module "container_app_environment" {
  source = "../../modules/container-app-environment"

  container_app_environment_name = var.container_app_environment_name
  resource_group_name            = module.resource_group.name
  location                       = var.location
  common_tags                    = local.common_tags
  infrastructure_subnet_id       = module.subnet_container_apps_environment.id
}

module "monitoring" {
  source = "../../modules/monitoring"

  name                = var.log_analytics_workspace_name
  resource_group_name = module.resource_group.name
  location            = var.location
  sku                 = var.log_analytics_sku
  environment         = local.environment
  project             = local.project
  common_tags         = local.common_tags
}

data "azurerm_client_config" "current" {}
