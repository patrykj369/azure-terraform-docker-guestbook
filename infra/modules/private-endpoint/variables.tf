variable "name" {
  description = "The name of the private endpoint."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the private endpoint."
  type        = string
}

variable "location" {
  description = "The Azure region in which to create the private endpoint."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet in which to create the private endpoint."
  type        = string
}

variable "private_service_connection" {
  description = "The private service connection configuration for the private endpoint."
  type = object({
    name                           = string
    private_connection_resource_id = string
    is_manual_connection          = bool
    subresource_names              = optional(list(string), [])
  })
}

variable "private_dns_zone_group" {
  description = "The private DNS zone group configuration for the private endpoint."
  type = object({
    name = string
    private_dns_zone_configs = list(object({
      name                = string
      private_dns_zone_ids = list(string)
    }))
  })
}