resource "azurerm_resource_group" "global_rg" {
  location = var.location
  name     = "Global-rg"
}

resource "azurerm_dns_zone" "parent" {
  name                = var.dev_domain_name
  resource_group_name = azurerm_resource_group.global_rg.name

  depends_on = [ azurerm_resource_group.global_rg ]
}

resource "azurerm_dns_txt_record" "validation_record" {
  name                = "@"
  zone_name           = azurerm_dns_zone.parent.name
  resource_group_name = azurerm_resource_group.global_rg.name
  ttl                 = 3600
  
  record {
    value = "MS=ms96251819"
  }

  depends_on = [ azurerm_dns_zone.parent ]
}

resource "namecheap_domain_records" "namecheap_domain" {
  domain = var.domain_name
  mode = "OVERWRITE"
  # nameservers = azurerm_dns_zone.parent.name_servers

  record {
    hostname = var.dev_subdomain
    type = "NS"
    address = tolist(azurerm_dns_zone.parent.name_servers)[0]
    ttl = 60
  }

  depends_on = [ azurerm_dns_zone.parent  ]
}

resource "azurerm_storage_account" "table_account" {
  name                     = "ta${lower(var.random_id)}"
  resource_group_name      = azurerm_resource_group.global_rg.name
  location                 = azurerm_resource_group.global_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  depends_on = [ azurerm_resource_group.global_rg ]
}

resource "azurerm_storage_table" "score_table" {
  name                 = "scoretable"
  storage_account_name = azurerm_storage_account.table_account.name
  depends_on = [ azurerm_storage_account.table_account ]
}

resource "azurerm_container_registry" "registry" {
  name                     = "${lower(var.random_id)}"
  resource_group_name      = azurerm_resource_group.global_rg.name
  location                 = var.location
  sku                      = "Standard"
  admin_enabled            = false
}
