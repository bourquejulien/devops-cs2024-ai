output "rg_name" {
  value = azurerm_resource_group.global_rg.name
}

output "parent_dns_name" {
  value = azurerm_dns_zone.parent.name
}

output "table_endpoint" {
  value = azurerm_storage_account.table_account.primary_table_endpoint
}
