resource "azuread_application" "app" {
  display_name        = "${var.side_name}app"
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
  depends_on = [ azuread_application.app ]
}

resource "azuread_service_principal_password" "app" {
  service_principal_id = azuread_service_principal.app.id
  end_date = "2025-12-31T09:00:00Z"
}

resource "azuread_user" "team_user" {
  count = var.is_team_cluster ? 1 : 0
  user_principal_name = "team${var.team_name}@${var.parent_dns.name}"
  display_name        = "Team${var.team_name}"
  mail_nickname       = "Team${var.team_name}"
  password            = "SecretP@sswd99!"
}

resource "azuread_application_federated_identity_credential" "federated_identity" {
  application_id = azuread_application.app.id
  display_name   = "Gitlab"
  description    = "Gitlab deployments"
  audiences      = ["https://gitlab.com"]
  issuer         = "https://gitlab.com"
  subject        = "project_path:devops-rusters/jungle:ref_type:branch:ref:main" # TODO
}

resource "azurerm_dns_zone" "dns" {
  name                = "${var.side_name}${var.team_name}.${var.parent_dns.name}"
  resource_group_name = var.rg_name
}

resource "azurerm_dns_ns_record" "ns_record" {
  name                = "${var.side_name}${var.team_name}"
  zone_name           = var.parent_dns.name
  resource_group_name = var.parent_dns.rg_name
  ttl                 = 60

  records = azurerm_dns_zone.dns.name_servers
}

resource "azurerm_public_ip" "ip" {
  name                = "${var.side_name}${var.team_name}ip"
  location            = "East US"
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_role_assignment" "network_contributor_role" {
  scope                = var.rg_id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.app.object_id
  skip_service_principal_aad_check = true
  depends_on = [ azuread_service_principal.app ]
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
    vnet_subnet_id = var.subnet_id
    temporary_name_for_rotation = "tmpnodepool"
  }

  service_principal {
    client_id     = azuread_application.app.client_id
    client_secret = azuread_service_principal_password.app.value
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"

    load_balancer_profile {
      outbound_ip_address_ids = [ azurerm_public_ip.ip.id ]
    }
  }

  depends_on = [ azurerm_public_ip.ip ]
}

resource "azurerm_dns_a_record" "a_record" {
  name                = "@"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = var.rg_name
  ttl                 = 300
  records             = [ azurerm_public_ip.ip.ip_address ]
  depends_on = [ azurerm_public_ip.ip ]
}

resource "azurerm_container_registry" "registry" {
  name                     = "${var.side_name}${var.team_name}${lower(var.random_id)}"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  sku                      = "Standard"
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

resource "azurerm_role_assignment" "acr_role_user" {
  count = var.is_team_cluster ? 1 : 0
  scope                            = azurerm_container_registry.registry.id
  role_definition_name             = "Contributor"
  principal_id                     = azuread_user.team_user[0].object_id
}

resource "azurerm_role_assignment" "aks_role_user" {
  count = var.is_team_cluster ? 1 : 0
  scope                            = azurerm_kubernetes_cluster.cluster.id
  role_definition_name             = "Contributor"
  principal_id                     = azuread_user.team_user[0].object_id
}
