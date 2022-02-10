# resource "azurerm_resource_group" "rg" {
#  name     = var.resource_group_name
#  location = var.resource_group_location
# }


module "k8s_setup" {
  source = "github.com/MavenCode/terraform-azure-k8s.git"

  cluster_name            = var.cluster_name
  resource_group_name     = "k8s_test"
  resource_group_location = "eastus"
  dns_prefix              = var.dns_prefix
  node_pool_name          = var.node_pool_name
  node_pool_count         = var.node_pool_count
  node_pool_vm_size       = var.node_pool_vm_size
  node_pool_osdisk_size   = var.node_pool_osdisk_size
  node_pool_max_count     = var.node_pool_max_count
  node_pool_min_count     = var.node_pool_min_count
  network_plugin          = var.network_plugin
  load_balancer_sku       = var.load_balancer_sku
  env                     = var.env
  client_id               = var.client_id
  client_secret           = var.client_secret
}

# module "datalakes" {
#   source                   = "git@github.com:MavenCode/terraform-azure-storage.git"
#   storage_account_name     = var.storage_account_name
#   resource_group_name      = azurerm_resource_group.rg.name
#   resource_group_location  = azurerm_resource_group.rg.location
#   account_tier             = var.account_tier
#   account_replication_type = var.account_replication_type
#   account_kind             = var.account_kind
#   env_name                 = var.env_name

# }
# resource "azurerm_container_registry" "acr" {

#   source = "git@github.com:MavenCode/azure-terraform-acr.git"

#   name                = var.acr_name
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   sku = "Premium"

#   admin_enabled = true
# }
