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

  server_name         = var.sql_server_name
  database_name       = var.sql_database_name
  resource_group_name = module.resource_group.name
  location            = var.location
  admin_login         = var.sql_admin_login
  admin_password      = var.sql_admin_password
  sku_name            = var.sql_sku_name
  environment         = local.environment
  project             = local.project
  common_tags         = local.common_tags
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
}

# module "container_app" {
#   source = "../../modules/container-app"

#   name                      = var.container_app_name
#   resource_group_name       = module.resource_group.name
#   location                  = var.location
#   container_app_environment = var.container_app_environment
#   image_name                = "${module.container_registry.login_server}/${var.image_name}"
#   image_tag                 = var.image_tag
#   environment               = local.environment
#   project                   = local.project
#   common_tags               = local.common_tags
#   managed_identity_id       = module.managed_identity.id
# }

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
