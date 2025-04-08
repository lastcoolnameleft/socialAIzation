resource "azurerm_container_app_environment" "container_env" {
  name                       = "${var.app_name}-${var.environment_name}-acaenv"
  location                   = var.location
  resource_group_name        = var.resource_group_name  # Comes from variables.tf
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
  depends_on                 = [ azurerm_resource_group.devsocialaization, azurerm_log_analytics_workspace.log_analytics ]
}

resource "azurerm_container_app" "scenario_ui" {
  name                         = "${var.app_name}-${var.environment_name}-scen-ui"
  container_app_environment_id = azurerm_container_app_environment.container_env.id # Referencing the environment ID
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "scenario-ui"
      image  = var.scenario_ui_container_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "VITE_API_URL"
        value = "https://${azurerm_container_app.conversation_api.ingress[0].fqdn}/api"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  depends_on           = [ azurerm_resource_group.devsocialaization, azurerm_container_app_environment.container_env, azurerm_container_app.scenario_api ]
}

resource "azurerm_container_app" "scenario_api" {
  name                         = "${var.app_name}-${var.environment_name}-scen-api"
  container_app_environment_id = azurerm_container_app_environment.container_env.id # Referencing the environment ID
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "scenario-api"
      image  = var.scenario_api_container_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "MONGODB_CONNECTION_STRING"
        value = azurerm_cosmosdb_account.mongodb.primary_sql_connection_string
      }
      env {
        name  = "MONGODB_DATABASE_NAME"
        value = var.mongodb_database_name
      }
      env {
        name  = "MONGODB_USER_COLLECTION"
        value = var.mongodb_user_collection
      }
      env {
        name  = "MONGODB_SCENARIO_COLLECTION"
        value = var.mongodb_scenario_collection
      }
      env {
        name  = "MONGODB_SESSION_COLLECTION"
        value = var.mongodb_session_collection
      }
      env {
        name  = "MONGODB_INTERACTION_COLLECTION"
        value = var.mongodb_interaction_collection
      }
      env {
        name  = "CORS_ORIGIN"
        value = "*"
      }
      env {
        name  = "PORT"
        value = "3000"
      }
      env {
        name  = "NODE_ENV"
        value = "dev"
      }
      env {
        name  = "JWT_SECRET"
        value = "ignore"
      }
      env {
        name  = "JWT_EXPIRY"
        value = "1d"
      }
      env {
        name  = "SECRETS_PROVIDER"
        value = "env"
      }
      env {
        name  = "KEY_VAULT_NAME"
        value = "ignore"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
  depends_on           = [ azurerm_resource_group.devsocialaization, azurerm_container_app_environment.container_env, azurerm_cosmosdb_account.mongodb ]
}

resource "azurerm_container_app" "conversation_api" {
  name                         = "${var.app_name}-${var.environment_name}-conv-api"
  container_app_environment_id = azurerm_container_app_environment.container_env.id # Referencing the environment ID
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "conversation-api"
      image  = var.conversation_api_container_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "AZURE_OPENAI_API_KEY"
        value = var.azure_openai_api_key
      }
      env {
        name  = "DEPLOYMENT_NAME"
        value = var.azure_openai_deployment_name
      }
      env {
        name  = "API_VERSION"
        value = var.azure_openai_api_version
      }
      env {
        name  = "AZURE_OPENAI_ENDPOINT"
        value = var.azure_openai_endpoint
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  depends_on           = [ azurerm_resource_group.devsocialaization, azurerm_container_app_environment.container_env ]
}