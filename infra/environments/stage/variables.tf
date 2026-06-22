variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "polandcentral"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-guestbook-stage"
}

# Container Registry Variables
variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "acrguestbookstage"
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
  default     = "sqlserver-guestbook-stage"
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
  default     = "sqldb-guestbook-stage"
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

variable "sql_sku_name" {
  description = "SKU for SQL Database"
  type        = string
  default     = "Standard"
}

# Key Vault Variables
variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-guestbook-stage"
}

# Container App Variables
variable "container_app_name" {
  description = "Name of the Container App"
  type        = string
  default     = "app-guestbook-stage"
}

variable "container_app_environment" {
  description = "Container App Environment name"
  type        = string
  default     = "cae-guestbook-stage"
}

variable "image_name" {
  description = "Container image name"
  type        = string
  default     = "guestbook"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "initial"
}

# Monitoring Variables
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "law-guestbook-stage"
}

variable "log_analytics_sku" {
  description = "Log Analytics SKU"
  type        = string
  default     = "PerGB2018"
}
