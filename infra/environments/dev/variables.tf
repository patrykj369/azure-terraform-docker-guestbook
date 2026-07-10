variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "polandcentral"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-guestbook-dev"
}

variable "virtual_network_name" {
  description = "Name of the Azure virtual network"
  type        = string
  default     = "vnet-guestbook-dev"
}

variable "virtual_network_address_space" {
  description = "Address space for the Azure virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# Container Registry Variables
variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "acrguestbookdev"
}

variable "acr_sku" {
  description = "SKU for Container Registry"
  type        = string
  default     = "Basic"
}

# SQL Database Variables
variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
  default     = "sqlserver-guestbook-dev"
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
  default     = "sqldb-guestbook-dev"
}

variable "sql_admin_login" {
  description = "SQL Server administrator login"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "sql_public_network_access_enabled" {
  description = "Enable or disable public network access to the SQL Server"
  type        = bool
  default     = false
}

variable "sql_sku_name" {
  description = "SKU for SQL Database"
  type        = string
  default     = "Basic"
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-guestbook-dev"
}

variable "key_vault_admin_principal_ids" {
  description = "List of Entra ID object IDs that should have Key Vault Administrator role on the Key Vault."
  type        = list(string)
  default     = []
}

variable "key_vault_network_acl_ip_rules" {
  description = "Public IPv4 addresses or CIDR ranges allowed to access the Key Vault data plane in addition to the Container Apps subnet."
  type        = list(string)
  default     = []
}

variable "container_app_environment_name" {
  description = "Container App Environment name"
  type        = string
  default     = "cae-guestbook-dev"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "law-guestbook-dev"
}

variable "log_analytics_sku" {
  description = "Log Analytics SKU"
  type        = string
  default     = "PerGB2018"
}
