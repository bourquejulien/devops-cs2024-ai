output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "table_endpoint" {
  value = azurerm_storage_account.table_account.primary_table_endpoint
}

output "ai_kube_host" {
  value     = module.ai_cluster.kube_host
  sensitive = true
}

output "ai_kube_client_certificate" {
  value     = module.ai_cluster.kube_client_certificate
  sensitive = true
}

output "ai_kube_client_key" {
  value     = module.ai_cluster.kube_client_key
  sensitive = true
}

output "ai_kube_ca_certificate" {
  value     = module.ai_cluster.kube_ca_certificate
  sensitive = true
}

output "team_kube_host" {
  value     = module.team_cluster.kube_host
  sensitive = true
}

output "team_kube_client_certificate" {
  value     = module.team_cluster.kube_client_certificate
  sensitive = true
}

output "team_kube_client_key" {
  value     = module.team_cluster.kube_client_key
  sensitive = true
}

output "team_kube_ca_certificate" {
  value     = module.team_cluster.kube_ca_certificate
  sensitive = true
}
