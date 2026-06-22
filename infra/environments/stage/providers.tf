terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.0"

  # Backend configuration for Azure Storage
  # Uses OIDC authentication instead of connection strings or access keys
  # Configure backend via CLI: 
  # terraform init -backend-config="resource_group_name=..." \
  #                 -backend-config="storage_account_name=..." \
  #                 -backend-config="container_name=..." \
  #                 -backend-config="key=stage.tfstate" \
  #                 -backend-config="use_oidc=true"
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

  # Provider will use OIDC token from ARM_OIDC_TOKEN environment variable
  # Set by GitHub Actions when using azure/login@v2
  skip_provider_registration = false
}
