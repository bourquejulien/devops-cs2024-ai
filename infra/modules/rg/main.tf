resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = format("%s-%s-rg", "CS", var.team_name)
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

resource "azurerm_container_registry" "team_registry" {
  name                     = "team${var.team_name}${lower(var.random_id)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Standard"
  admin_enabled            = false
}

resource "azuread_user" "team_user" {
  user_principal_name = "team${var.team_name}@${var.parent_dns.main_dns_name}"
  display_name        = "Team${var.team_name}"
  mail_nickname       = "Team${var.team_name}"
  password            = var.team_user_password
}

module "team_cluster" {
  rg_name = azurerm_resource_group.rg.name
  rg_id = azurerm_resource_group.rg.id
  subnet_id = azurerm_subnet.team.id
  rg_location = azurerm_resource_group.rg.location
  random_id = var.random_id
  side_name = "team"
  team_name = var.team_name
  acr_id = azurerm_container_registry.team_registry.id
  team_user_id = azuread_user.team_user.object_id
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
  acr_id = var.ai_acr_id
  team_name = var.team_name
  team_user_id = ""
  source = "../cluster"
  is_team_cluster = false
  parent_dns = var.parent_dns
  depends_on = [ azurerm_resource_group.rg, azurerm_subnet.team]
}
