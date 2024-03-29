<p align="center">
  <img src="https://github.com/intel/terraform-intel-azure-aks/blob/main/images/logo-classicblue-800px.png?raw=true" alt="Intel Logo" width="250"/>
</p>

# Intel® Optimized Cloud Modules for Terraform

© Copyright 2024, Intel Corporation

## Azure AKS Module

Simple usage of the module

## Usage

**See examples folder for complete examples**

Example of main.tf

```hcl

#########################################################
# Local variables, modify for your needs                #
#########################################################

########################
####     Intel      ####
########################

# See POLICIES.md, we recommend  Intel Xeon 3rd Generation Scalable processors (code-named Ice Lake)
# Storage Optimized: Standard_L8s_v3, Standard_L16s_v3, Standard_L32s_v3, Standard_L48s_v3, Standard_L64s_v3, Standard_L80s_v3, 
# General Purpose: Standard_D2_v5, Standard_D4_v5, Standard_D8_v5, Standard_D16_v5, Standard_D32_v5, Standard_D48_v5, Standard_D64_v5, Standard_D96_v5, Standard_D2d_v5, Standard_D4d_v5, Standard_D8d_v5, Standard_D16d_v5, Standard_D32d_v5, Standard_D48d_v5, Standard_D64d_v5, Standard_D96d_v5, Standard_D2ds_v5, Standard_D4ds_v5, Standard_D8ds_v5, Standard_D16ds_v5, Standard_D32ds_v5, Standard_D48ds_v5, Standard_D64ds_v5, Standard_D96ds_v5, Standard_DC1s_v3, Standard_DC2s_v3, Standard_DC4s_v3, Standard_DC8s_v3, Standard_DC16s_v3, Standard_DC24s_v3, Standard_DC32s_v3, Standard_DC48s_v3, Standard_DC1ds_v3, Standard_DC2ds_v3, Standard_DC4ds_v3, Standard_DC8ds_v3, Standard_DC16ds_v3, Standard_DC24ds_v3, Standard_DC32ds_v3, Standard_DC48ds_v3
# Memory Optimized: Standard_E2_v5, Standard_E4_v5, Standard_E8_v5, Standard_E16_v5, Standard_E20_v5, Standard_E32_v5, Standard_E48_v5, Standard_E64_v5, Standard_E96_v5, Standard_E104i_v5, Standard_E2bs_v5, Standard_E4bs_v5, Standard_E8bs_v5, Standard_E16bs_v5, Standard_E32bs_v5, Standard_E48bs_v5, Standard_E64bs_v5, Standard_E2bds_v5, Standard_E4bds_v5, Standard_E8bds_v5, Standard_E16bds_v5, Standard_E32bds_v5, Standard_E48bds_v5, Standard_E64bds_v5
# See more:
# https://learn.microsoft.com/en-us/azure/virtual-machines/dv5-dsv5-series
# https://learn.microsoft.com/en-us/azure/virtual-machines/ev5-esv5-series
# https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/#pricing

locals {
  # See above recommended instance types for Intel Xeon 3rd Generation Scalable processors (code-named Ice Lake)
  #AKS Default node pool
  vm_size = "Standard_D4ds_v5"

  # AKS Node Pool 02 Config
  node_pools = {
    nodepool02 = {
      name                           = "nodepool02"
      vm_size                        = "Standard_D16_v5"
      enable_auto_scaling            = true
      node_count                     = null
      min_count                      = 1
      max_count                      = 8
      os_disk_type                   = "Managed"
      vnet_subnet_id                 = data.azurerm_subnet.subnet.id
      net_profile_docker_bridge_cidr = "170.12.0.1/16"
      net_profile_service_cidr       = "10.12.0.0/16"
      net_profile_dns_service_ip     = "10.12.0.10"
      tags = {
        Owner    = "user@example.com"
        Module    = "Intel.Cloud.Optimization.Modules"
        Duration = "1"
      }      

    },

    # AKS Node Pool 02 Config
    nodepool03 = {
      name                           = "nodepool03"
      vm_size                        = "Standard_E8_v5"
      enable_auto_scaling            = true
      node_count                     = null
      min_count                      = 1
      max_count                      = 4
      os_disk_type                   = "Managed"
      vnet_subnet_id                 = data.azurerm_subnet.subnet.id
      net_profile_docker_bridge_cidr = "170.13.0.1/16"
      net_profile_service_cidr       = "10.13.0.0/16"
      net_profile_dns_service_ip     = "10.13.0.10"
      # Tags
      tags = {
        Owner    = "user@example.com"
        Module    = "Intel.Cloud.Optimization.Modules"
        Duration = "1"
      }

    }
    
  }
  
  # AKS RG and Network Config
  resource_group_name                 = "terraform-testing-rg"
  virtual_network_name                = "akscluster50vnet"
  virtual_network_resource_group_name = "terraform-testing-rg"
  subnet_name                         = "default"
}
#########################################################
# End of local variables                                #
#########################################################

resource "random_id" "prefix" {
  byte_length = 8
}

data "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  virtual_network_name = local.virtual_network_name
  resource_group_name  = local.virtual_network_resource_group_name
}

# Azure AKS Module, see the following for options https://github.com/Azure/terraform-azurerm-aks/blob/main/variables.tf
module "intel-aks-cluster" {
 source = "github.com/Azure/terraform-azurerm-aks"
 # source              = "Azure/aks/azurerm"
 # version             = "~>6.7.1"
  prefix              = "cluster-${random_id.prefix.hex}"
  resource_group_name = local.resource_group_name
  admin_username      = "aksadmin"

  # Intel Instance selection 
  agents_size = local.vm_size

  # Default AKS Node Pool Config
  agents_pool_name               = "nodepool01"
  enable_auto_scaling            = true
  agents_availability_zones      = ["1", "2", "3"]
  agents_count                   = null
  agents_min_count               = 1
  agents_max_count               = 18 # 6 nodes per AZ
  agents_max_pods                = 100
  os_disk_type                   = "Ephemeral" # Requires local temp disk, enhances performance and speeds up maintenance
  vnet_subnet_id                 = data.azurerm_subnet.subnet.id
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.10.0.0/16"
  net_profile_dns_service_ip     = "10.10.0.10"

  # Other Node Pool Config
  node_pools          = local.node_pools

  # AKS Config
  http_application_routing_enabled = true
  kubernetes_version               = "1.25" # Don't specify the patch version!
  automatic_channel_upgrade        = "patch"
  sku_tier                         = "Paid"
  private_cluster_enabled          = false
  log_analytics_workspace_enabled  = false

  # RBAC Config
  rbac_aad                          = true
  rbac_aad_managed                  = true
  role_based_access_control_enabled = true

  # Tags
  tags = {
    Owner    = "user@example.com"
    Module    = "Intel.Cloud.Optimization.Modules"
    Duration = "1"
  }
}

```

Run Terraform

```hcl
terraform init  
terraform plan
terraform apply

```

## Considerations  

Note that this code base will create resources. Run `terraform destroy` when you don't need these resources anymore to minimize costs.  