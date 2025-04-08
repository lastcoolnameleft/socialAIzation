# https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/create-hub-terraform?tabs=azure-cli

# Create an Azure Key Vault resource
resource "azurerm_key_vault" "ai_key_vault" {
  name                = random_string.rando.result                 # Name of the Key Vault
  location            = azurerm_resource_group.devsocialaization.location      # Location from the resource group
  resource_group_name = azurerm_resource_group.devsocialaization.name          # Resource group name
  tenant_id           = data.azurerm_client_config.current.tenant_id # Azure tenant ID

  sku_name                 = "standard" # SKU tier for the Key Vault
  purge_protection_enabled = true       # Enables purge protection to prevent accidental deletion
}

# Set an access policy for the Key Vault to allow certain operations
resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.ai_key_vault.id                 # Key Vault reference
  tenant_id    = data.azurerm_client_config.current.tenant_id # Tenant ID
  object_id    = data.azurerm_client_config.current.object_id # Object ID of the principal

  key_permissions = [ # List of allowed key permissions
    "Create",
    "Get",
    "Delete",
    "Purge",
    "GetRotationPolicy",
  ]
}

# https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/create-hub-terraform?tabs=azure-cli
# Create an Azure Storage Account
resource "azurerm_storage_account" "ai_storage" {
  name                     = var.storage_account_name                # Storage account name
  location                 = azurerm_resource_group.devsocialaization.location # Location from the resource group
  resource_group_name      = azurerm_resource_group.devsocialaization.name     # Resource group name
  account_tier             = "Standard"                              # Performance tier
  account_replication_type = "LRS"                                   # Locally-redundant storage replication
}

# Deploy Azure AI Services resource
resource "azurerm_ai_services" "ai_services" {
  name                = "${var.app_name}-${var.environment_name}-ai-svc"  # AI Services resource name
  location            = azurerm_resource_group.devsocialaization.location # Location from the resource group
  resource_group_name = azurerm_resource_group.devsocialaization.name     # Location from the resource group
  sku_name            = "S0"                                              # Pricing SKU tier
}

# Create Azure AI Foundry service
resource "azurerm_ai_foundry" "ai_foundry" {
  name                = "${var.app_name}-${var.environment_name}-ai-foundry" # AI Foundry service name
  location            = azurerm_resource_group.devsocialaization.location # Location from the resource group
  resource_group_name = azurerm_resource_group.devsocialaization.name     # Location from the resource group
  storage_account_id  = azurerm_storage_account.ai_storage.id   # Associated storage account
  key_vault_id        = azurerm_key_vault.ai_key_vault.id         # Associated Key Vault

  identity {
    type = "SystemAssigned" # Enable system-assigned managed identity
  }
}

# Create an AI Foundry Project within the AI Foundry service
resource "azurerm_ai_foundry_project" "ai_foundry" {
  name               = "conversation_api"                           # Project name
  location            = azurerm_resource_group.devsocialaization.location # Location from the resource group
  ai_services_hub_id = azurerm_ai_foundry.ai_foundry.id       # Associated AI Foundry service

  identity {
    type = "SystemAssigned" # Enable system-assigned managed identity
  }
}
