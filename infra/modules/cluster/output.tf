output "kube_host" {
  value     = azurerm_kubernetes_cluster.cluster.kube_config.0.host
  sensitive = true
}

output "kube_client_certificate" {
  value     = azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate
  sensitive = true
}

output "kube_client_key" {
  value     = azurerm_kubernetes_cluster.cluster.kube_config.0.client_key
  sensitive = true
}

output "kube_ca_certificate" {
  value     = azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate
  sensitive = true
}
