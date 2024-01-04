resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = format("%s-%s-rg", "CS", var.team_name)
}

resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azuread_application" "aiapp" {
  display_name        = "aiapp"
}

resource "azuread_service_principal" "aiapp" {
  client_id = azuread_application.aiapp.client_id
}

resource "azuread_service_principal_password" "aiapp" {
  service_principal_id = azuread_service_principal.aiapp.id
  end_date = "2025-12-31T09:00:00Z"
}

resource "azuread_application" "teamapp" {
  display_name        = "teamapp"
}

resource "azuread_service_principal" "teamapp" {
  client_id = azuread_application.teamapp.client_id
}

resource "azuread_service_principal_password" "teamapp" {
  service_principal_id = azuread_service_principal.teamapp.id
  end_date = "2025-12-31T09:00:00Z"
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

  service_principal {
    client_id     = azuread_service_principal.aiapp.application_id
    client_secret = azuread_service_principal_password.aiapp.value
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

  service_principal {
    client_id     = azuread_service_principal.teamapp.application_id
    client_secret = azuread_service_principal_password.teamapp.value
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

resource "azurerm_container_registry" "ai_registry" {
  name                     = "aiacr${lower(random_id.storage_account.hex)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = false
}

resource "azurerm_container_registry" "team_registry" {
  name                     = "teamacr${lower(random_id.storage_account.hex)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = false
}

resource "azurerm_role_assignment" "ai_acrpull_role" {
  scope                            = azurerm_container_registry.ai_registry.id
  role_definition_name             = "AcrPull"
  principal_id                     = azuread_service_principal.aiapp.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "team_acrpull_role" {
  scope                            = azurerm_container_registry.team_registry.id
  role_definition_name             = "AcrPull"
  principal_id                     = azuread_service_principal.teamapp.object_id
  skip_service_principal_aad_check = true
}
