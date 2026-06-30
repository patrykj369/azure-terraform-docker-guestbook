variable "subnet_id" {
  description = "The ID of the subnet to associate with the network security group."
  type        = string
}

variable "nsg_id" {
  description = "The ID of the network security group to associate with the subnet."
  type        = string
}