variable "name" {
  description = "Name of the container app"
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

variable "container_app_environment" {
  description = "Name of the container app environment"
  type        = string
}

variable "image_name" {
  description = "Container image name with registry"
  type        = string
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "initial"
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

variable "managed_identity_id" {
  description = "ID of the user-assigned managed identity"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name      = string
    value     = optional(string)
    secret_ref = optional(string)
  }))
  default = []
}
