resource "azurerm_container_app_environment" "main" {
  name                = var.container_app_environment
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_container_app" "main" {
  name                         = var.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  template {
    container {
      name   = var.name
      image  = "${var.image_name}:${var.image_tag}"
      cpu    = "0.5"
      memory = "1Gi"

      # Example: Add environment variables with Key Vault references
      # Environment variables can reference Key Vault secrets via secretref:
      # dynamic "env" {
      #   for_each = var.environment_variables
      #   content {
      #     name        = env.value.name
      #     secret_name = env.value.secret_ref
      #   }
      # }
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 8080
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.common_tags

  # Ignore changes to image to allow updates via az containerapp update
  # Pipeline will handle image updates separately
  lifecycle {
    ignore_changes = [
      template[0].container[0].image
    ]
  }
}

