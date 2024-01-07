resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = format("%s-%s-rg", "CS", var.team_name)
}

resource "azurerm_storage_account" "table_account" {
  name                     = "ta${var.team_name}${lower(var.random_id)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "score_table" {
  name                 = "scoretable"
  storage_account_name = azurerm_storage_account.table_account.name
}

module "team_cluster" {
  rg_name = azurerm_resource_group.rg.name
  rg_id = azurerm_resource_group.rg.id
  rg_location = azurerm_resource_group.rg.location
  random_id = var.random_id
  side_name = "team"
  team_name = var.team_name
  source = "../cluster"
  parent_dns = var.parent_dns
}

module "ai_cluster" {
  rg_name = azurerm_resource_group.rg.name
  rg_location = azurerm_resource_group.rg.location
  rg_id = azurerm_resource_group.rg.id
  random_id = var.random_id
  side_name = "ai"
  team_name = var.team_name
  source = "../cluster"
  parent_dns = var.parent_dns
}
