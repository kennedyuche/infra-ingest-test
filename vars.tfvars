# storage_account_name     = "docai-storage"
# account_tier             = "Standard"
# account_replication_type = "LRS"
# account_kind             = "StorageV2"
# env_name                 = "dev"

cluster_name          = "test"
node_pool_name        = "default"
node_pool_count       = 2
node_pool_vm_size     = "Standard_E4s_v3"
node_pool_osdisk_size = 50
node_pool_max_count   = 5
node_pool_min_count   = 1
network_plugin="kubenet"
load_balancer_sku ="Standard"
dns_prefix = "k8scluster"
env = "dev"


# resource_group_name     = "docai-dev"
# resource_group_location = "North Europe"