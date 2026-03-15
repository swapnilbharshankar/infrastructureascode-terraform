variable "vnet_name" {
    description = "Name of the virtual network to which the VM will be connected"
    type        = string
    default     = "my-network"
}

variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
    default     = "azure-free"
}

variable "subnet_name" {
    description = "Name of the subnet to which the VM will be connected"
    type        = string
    default     = "my-subnet"
}

variable "location" {
    description = "Location of the virtual machine"
    type        = string
    default     = "centralindia"
}

variable "virtual_machines" {
    description = "A map of virtual machines to create, where the key is the name of the virtual machine and the value is an object containing the properties of the virtual machine."
    type = list(object(
        {
            name = string,
            create_public_ip_address = bool,
            size = string,
            username = string,
            public_key_path = string,
            source_image_reference = object(
                { publisher = string, offer = string, sku = string, version = string }
            )
        }
    ))
}