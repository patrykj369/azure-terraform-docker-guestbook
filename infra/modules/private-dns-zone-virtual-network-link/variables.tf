variable "name" {
  description = "The name of the private DNS zone virtual network link."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the private DNS zone virtual network link."
  type        = string
}

variable "private_dns_zone_name" {
  description = "The name of the private DNS zone to link to the virtual network."
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the virtual network to link to the private DNS zone."
  type        = string
}