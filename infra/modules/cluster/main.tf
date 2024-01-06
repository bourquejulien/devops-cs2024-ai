resource "azuread_application" "app" {
  display_name        = "${var.side_name}app"
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
}

resource "azuread_application_federated_identity_credential" "federated_identity" {
  application_id = azuread_application.app.id
  display_name   = "Gitlab"
  description    = "Gitlab deployments"
  audiences      = ["https://gitlab.com"]
  issuer         = "https://gitlab.com"
  subject        = "project_path:devops-rusters/jungle:ref_type:branch:ref:main" # TODO
}

resource "azuread_service_principal_password" "app" {
  service_principal_id = azuread_service_principal.app.id
  end_date = "2025-12-31T09:00:00Z"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.side_name}cluster"
  location            = var.rg_location
  resource_group_name = var.rg_name
  dns_prefix          = "${var.side_name}cluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  service_principal {
    client_id     = azuread_application.app.client_id
    client_secret = azuread_service_principal_password.app.value
  }
}

resource "azurerm_container_registry" "registry" {
  name                     = "${var.side_name}${var.team_name}${lower(var.random_id)}"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  sku                      = "Basic"
  admin_enabled            = false
}

resource "azurerm_role_assignment" "acr_role" {
  scope                            = azurerm_container_registry.registry.id
  role_definition_name             = "Contributor"
  principal_id                     = azuread_service_principal.app.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_role" {
  scope                            = azurerm_kubernetes_cluster.cluster.id
  role_definition_name             = "Contributor"
  principal_id                     = azuread_service_principal.app.object_id
  skip_service_principal_aad_check = true
}
