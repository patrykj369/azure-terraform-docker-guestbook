variable "server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "admin_login" {
  description = "Administrator login username"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Administrator login password"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "SKU name of the database"
  type        = string
  default     = "Basic"
}

variable "public_network_access_enabled" {
  description = "Enable or disable public network access to the SQL Server"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
