# Resource Group Outputs
output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.resource_group.id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.resource_group.name
}

# Container Registry Outputs
output "container_registry_id" {
  description = "ID of the Container Registry"
  value       = module.container_registry.id
}

output "container_registry_login_server" {
  description = "Login server of the Container Registry"
  value       = module.container_registry.login_server
}

# SQL Database Outputs
output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = module.sql_database.server_id
}

output "sql_server_fqdn" {
  description = "Fully Qualified Domain Name of the SQL Server"
  value       = module.sql_database.server_fqdn
}

output "sql_database_id" {
  description = "ID of the SQL Database"
  value       = module.sql_database.database_id
}

output "sql_connection_string" {
  description = "Connection string for the SQL Database"
  value       = module.sql_database.connection_string
  sensitive   = true
}

# Key Vault Outputs
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.key_vault.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.vault_uri
}

# Container App Outputs
# output "container_app_id" {
#   description = "ID of the Container App"
#   value       = module.container_app.id
# }

# output "container_app_url" {
#   description = "URL of the Container App"
#   value       = module.container_app.fqdn
# }

# Log Analytics Outputs
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = module.monitoring.workspace_id
}

output "log_analytics_workspace_customer_id" {
  description = "Customer ID of the Log Analytics Workspace"
  value       = module.monitoring.workspace_customer_id
}
