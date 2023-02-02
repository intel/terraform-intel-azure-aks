provider "azurerm" {
  version = "2.0"
}

resource "azurerm_resource_group" "aks_cluster" {
  name     = "aks_cluster_rg"
  location = "westus2"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_cluster.location
  resource_group_name = azurerm_resource_group.aks_cluster.name
  dns_prefix          = "akscluster"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_D2_v2"
  }

  linux_profile {
    admin_username = "aksuser"
    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
    }
  }

  service_principal {
    client_id     = "00000000-0000-0000-0000-000000000000"
    client_secret = "00000000-0000-0000-0000-000000000000"
  }

  network_profile {
    network_plugin    = "kubenet"
  }
}

