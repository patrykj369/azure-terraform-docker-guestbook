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

  template {
    container {
      name   = var.name
      image  = "${var.image_name}:${var.image_tag}"
      cpu    = "0.5"
      memory = "1Gi"
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 5000
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.common_tags
}
