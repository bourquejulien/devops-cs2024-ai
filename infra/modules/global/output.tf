output "rg_name" {
  value = azurerm_resource_group.global_rg.name
}

output "ai_acr_id" {
  value = azurerm_container_registry.registry.id
}

output "parent_dns_name" {
  value = azurerm_dns_zone.parent.name
}

output "table_endpoint" {
  value = azurerm_storage_account.table_account.primary_table_endpoint
}
