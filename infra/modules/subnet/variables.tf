variable "name" {
  description = "Name of the network security group"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_prefixes" {
  description = "List of address prefixes for the subnet"
  type        = list(string)
}

variable "service_endpoints" {
  description = "Optional list of service endpoints to enable on the subnet."
  type        = list(string)
  default     = []
}

variable "delegation" {
  description = "Optional subnet delegation configuration."
  type = object({
    name         = string
    service_name = string
    actions      = list(string)
  })
  default = null
}