
# Retrieve information about the current Azure client configuration
data "azurerm_client_config" "current" {}

# Generate random value for unique resource naming
resource "random_string" "rando" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_resource_group" "devsocialaization" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${var.app_name}-${var.environment_name}-la"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  depends_on          = [ azurerm_resource_group.devsocialaization ]
}

# MongoDB-compatible database using Azure Cosmos DB
resource "azurerm_cosmosdb_account" "mongodb" {
  name                = "${var.app_name}-db-${var.environment_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"
  ip_range_filter     = ["0.0.0.0"] # https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-global-azure-datacenters-or-other-sources-within-azure

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
  
  mongo_server_version = "4.2"

  depends_on           = [ azurerm_resource_group.devsocialaization ]
}

# Create a MongoDB database within the Cosmos account
resource "azurerm_cosmosdb_mongo_database" "main" {
  name                = "${var.app_name}-mongodb"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.mongodb.name
  depends_on          = [ azurerm_cosmosdb_account.mongodb ]
}