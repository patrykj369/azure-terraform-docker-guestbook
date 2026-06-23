terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateguestbookapp"
    container_name       = "tfstateguestbookapp"
    key                  = "dev.tfstate"
  }
}
