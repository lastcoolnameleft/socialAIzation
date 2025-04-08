# Output values that will be displayed after deployment
output "mongodb_connection_string" {
  value     = azurerm_cosmosdb_account.mongodb.primary_sql_connection_string
  sensitive = true
}

output "scenario_ui_url" {
  value = "https://${azurerm_container_app.scenario_ui.latest_revision_fqdn}"
}

output "scenario_api_url" {
  value = "https://${azurerm_container_app.scenario_ui.latest_revision_fqdn}/api"
}

output "conversation_api_url" {
  value = "https://${azurerm_container_app.scenario_ui.latest_revision_fqdn}/docs"
}