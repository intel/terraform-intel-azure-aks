output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}

output "aks_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.aks_cluster.fqdn
}

output "aks_cluster_resource_group" {
  value = azurerm_kubernetes_cluster.aks_cluster.resource_group_name
}

output "aks_cluster_location" {
  value = azurerm_kubernetes_cluster.aks_cluster.location
}
