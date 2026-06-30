variable "container_app_environment_name" {
  description = "Name of the container app environment"
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

variable "infrastructure_subnet_id" {
  description = "ID of the subnet for the container app environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

