terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.0"

  backend "azurerm" {
    use_oidc = true
  }
}

provider "azurerm" {
  features {
    key_vault {
      # Recover soft-deleted Key Vaults during apply
      recover_soft_deleted_key_vaults = true
      # Purge soft-deleted secrets during destroy
      purge_soft_deleted_secrets_on_destroy = false
    }
  }
}

