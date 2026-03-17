variable "location" {
    description = "Location of the AKS cluster"
    type        = string
    default     = "centralindia"
}

variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
    default     = "azure-free"
}

variable "aks_clusters" {
    description = "A map of AKS clusters to create, where the key is the name of the AKS cluster and the value is an object containing the properties of the AKS cluster."
    type = map(object({
        name                        = string
        dns_prefix                  = string
        kubernetes_version          = string
        admin_username              = string
        ssh_public_key_path         = string
        api_server_authorized_ip_ranges = list(string)
        private_cluster_enabled         = bool
        workload_autoscaler_profile = object({
            keda_enabled                    = bool
            vertical_pod_autoscaler_enabled = bool
        })
        default_node_pool = object({
            name                    = string
            vm_size                 = string
            node_count              = number
            vnet_subnet_id          = string
            auto_scaling_enabled    = bool
            min_count               = number
            max_count               = number
            zones                   = list(string)
            type                    = string
            os_disk_size_gb         = number
        })
        extra_node_pools = list(object({
            name                    = string
            vm_size                 = string
            node_count              = number
            vnet_subnet_id          = string
            auto_scaling_enabled    = bool
            min_count               = number
            max_count               = number
            zones                   = list(string)
            os_disk_size_gb         = number
            node_labels             = map(string)
            node_taints             = list(string)
        }))
    }))
    default = {}
  
}

variable "tags" {
    description = "A map of tags to assign to the resources."
    type        = map(string)
    default     = {}
}