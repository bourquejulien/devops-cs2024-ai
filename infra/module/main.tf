resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = format("%s-%s-rg", "CS", var.team_name)
}

resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_kubernetes_cluster" "ai_cluster" {
  name                = "ai-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aicluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
      type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster" "team_cluster" {
  name                = "team-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aicluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
      type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "table_account" {
  name                     = "ta${lower(random_id.storage_account.hex)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "score_table" {
  name                 = "scoretable"
  storage_account_name = azurerm_storage_account.table_account.name
}
