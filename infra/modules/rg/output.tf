output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "table_endpoint" {
  value = azurerm_storage_account.table_account.primary_table_endpoint
}
