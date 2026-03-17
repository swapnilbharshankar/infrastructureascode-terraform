output "azurem_kubernetes_clusters" {
    description = "A map of AKS clusters created, where the key is the name of the AKS cluster and the value is an object containing the properties of the AKS cluster."
    value = {
        for name, aks_cluster in azurem_kubernetes_cluster.this :
        name => {
            id                          = aks_cluster.id
            name                        = aks_cluster.name
            location                    = aks_cluster.location
            dns_prefix                  = aks_cluster.dns_prefix
            kubernetes_version          = aks_cluster.kubernetes_version
            node_resource_group         = aks_cluster.node_resource_group
            api_server_authorized_ip_ranges = aks_cluster.api_server_authorized_ip_ranges
            private_cluster_enabled         = aks_cluster.private_cluster_enabled
            workload_autoscaler_profile = {
                keda_enabled                    = aks_cluster.workload_autoscaler_profile.keda_enabled
                vertical_pod_autoscaler_enabled = aks_cluster.workload_autoscaler_profile.vertical_pod_autoscaler_enabled
            }
            default_node_pool = {
                name                    = aks_cluster.default_node_pool[0].name
                vm_size                 = aks_cluster.default_node_pool[0].vm_size
                node_count              = aks_cluster.default_node_pool[0].node_count
                vnet_subnet_id          = aks_cluster.default_node_pool[0].vnet_subnet_id
                auto_scaling_enabled    = aks_cluster.default_node_pool[0].auto_scaling_enabled
                min_count               = aks_cluster.default_node_pool[0].min_count
                max_count               = aks_cluster.default_node_pool[0].max_count
                zones                   = aks_cluster.default_node_pool[0].zones
                type                    = aks_cluster.default_node_pool[0].type
                os_disk_size_gb         = aks_cluster.default_node_pool[0].os_disk_size_gb
            }
        }
    }
}