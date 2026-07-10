variable "name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
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

variable "app_managed_identity_principal_id" {
  description = "Principal ID of the application's managed identity (for Key Vault access)"
  type        = string
  default     = ""
}

variable "app_managed_identity_name" {
  description = "Name of the application's managed identity"
  type        = string
  default     = ""
}

variable "key_vault_admin_principal_ids" {
  description = "List of Entra ID object IDs that should have Key Vault Administrator role on this Key Vault."
  type        = list(string)
  default     = []
}

variable "network_acl_ip_rules" {
  type    = list(string)
  default = []
}

variable "network_acl_subnet_ids" {
  type    = list(string)
  default = []
}

