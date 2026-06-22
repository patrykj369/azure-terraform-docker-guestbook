terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateguestbook"
    container_name       = "tfstateguestbook"
    key                  = "dev.tfstate"
  }
}
