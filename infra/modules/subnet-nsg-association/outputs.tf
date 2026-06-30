output "subnet_id" {
  description = "The ID of the subnet associated with the network security group."
  value       = azurerm_subnet_network_security_group_association.main.subnet_id
}