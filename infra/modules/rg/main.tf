resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = format("%s-%s-rg", "CS", var.team_name)
}

resource "azurerm_storage_account" "table_account" {
  name                     = "ta${var.team_name}${lower(var.random_id)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_storage_table" "score_table" {
  name                 = "scoretable"
  storage_account_name = azurerm_storage_account.table_account.name
  depends_on = [ azurerm_storage_account.table_account ]
}

resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.30.0.0/16"]
  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_private_dns_zone" "private_dns" {
  name                = "private.${var.parent_dns.name}"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_private_dns_a_record" "ai_a_record" {
  name                = "ai"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [ "10.30.11.10" ] # Set in validation service
  depends_on = [ azurerm_private_dns_zone.private_dns ]
}

resource "azurerm_private_dns_a_record" "team_a_record" {
  name                = "team"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [ "10.30.10.10" ] # Set in team service
  depends_on = [ azurerm_private_dns_zone.private_dns ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_link" {
  name                  = "private_link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  depends_on = [ azurerm_private_dns_zone.private_dns, azurerm_virtual_network.vnet ]
}

resource "azurerm_subnet" "ai" {
  name                 = "ai"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.11.0/24"]
  depends_on = [ azurerm_virtual_network.vnet ]
}

resource "azurerm_subnet" "team" {
  name                 = "team"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.10.0/24"]
  depends_on = [ azurerm_virtual_network.vnet ]
}

module "team_cluster" {
  rg_name = azurerm_resource_group.rg.name
  rg_id = azurerm_resource_group.rg.id
  subnet_id = azurerm_subnet.team.id
  rg_location = azurerm_resource_group.rg.location
  random_id = var.random_id
  side_name = "team"
  team_name = var.team_name
  source = "../cluster"
  is_team_cluster = true
  parent_dns = var.parent_dns
  depends_on = [ azurerm_resource_group.rg, azurerm_subnet.team ]
}

module "ai_cluster" {
  rg_name = azurerm_resource_group.rg.name
  rg_location = azurerm_resource_group.rg.location
  rg_id = azurerm_resource_group.rg.id
  subnet_id = azurerm_subnet.ai.id
  random_id = var.random_id
  side_name = "ai"
  team_name = var.team_name
  source = "../cluster"
  is_team_cluster = false
  parent_dns = var.parent_dns
  depends_on = [ azurerm_resource_group.rg, azurerm_subnet.team]
}
