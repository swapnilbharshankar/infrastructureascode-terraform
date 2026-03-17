
resource "azurem_kubernetes_cluster" "this" {
    for_each                    = var.aks_clusters
    name                        = each.value.name
    resource_group_name         = var.resource_group_name
    location                    = var.location
    dns_prefix                  = each.value.dns_prefix
    node_resource_group         = var.resource_group_name
    kubernetes_version          = each.value.kubernetes_version
    default_node_pool {
        name                    = each.value.default_node_pool.name
        vm_size                 = each.value.default_node_pool.vm_size
        node_count              = each.value.default_node_pool.node_count
        vnet_subnet_id          = each.value.default_node_pool.vnet_subnet_id
        auto_scaling_enabled    = each.value.default_node_pool.auto_scaling_enabled
        min_count               = each.value.default_node_pool.min_count
        max_count               = each.value.default_node_pool.max_count
        zones                   = each.value.default_node_pool.zones
        type                    = each.value.default_node_pool.type
        os_disk_size_gb         = each.value.default_node_pool.os_disk_size_gb
        tags                    = var.tags
    }
    linux_profile {
        admin_username  = each.value.admin_username
        ssh_key {
            key_data    = file(each.value.ssh_public_key_path)
        }
    }
    api_server_authorized_ip_ranges = each.value.api_server_authorized_ip_ranges
    private_cluster_enabled         = each.value.private_cluster_enabled
    identity {
        type = var.identity_type
    }
    workload_autoscaler_profile {
        keda_enabled                    = each.value.workload_autoscaler_profile.keda_enabled
        vertical_pod_autoscaler_enabled = each.value.workload_autoscaler_profile.vertical_pod_autoscaler_enabled
    }
    tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
    for_each = var.aks_clusters.extra_node_pools
    name                    = each.value.name
    kubernetes_cluster_id   = azurem_kubernetes_cluster.this[each.value.cluster_name].id
    vm_size                 = each.value.vm_size
    node_count              = each.value.node_count
    vnet_subnet_id          = each.value.vnet_subnet_id
    auto_scaling_enabled    = each.value.auto_scaling_enabled
    min_count               = each.value.min_count
    max_count               = each.value.max_count
    zones                   = each.value.zones
    os_disk_size_gb         = each.value.os_disk_size_gb
    node_labels             = each.value.node_labels
    node_taints             = each.value.node_taints
    tags                    = var.tags
}