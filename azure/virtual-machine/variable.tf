variable "vnet_name" {
    description = "Name of the virtual network to which the VM will be connected"
    type        = string
    default     = "my-network"
}

variable "name" {
    description = "Name of the virtual machine"
    type        = string
    default     = "my-vm"
}

variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
    default     = "azure-free"
}

variable "subnet_id" {
    description = "ID of the subnet to which the VM will be connected"
    type        = string
    default     = "id-of-the-subnet"
}

variable "location" {
    description = "Location of the virtual machine"
    type        = string
    default     = "centralindia"
}

variable "size" {
    description = "Size of the virtual machine"
    type        = string
    default     = "Standard_F2"
}

variable "username" {
    description = "Admin username for the virtual machine"
    type        = string
    default     = "adminuser"
}

variable "public_key_path" {
    description = "Path to the public SSH key for the virtual machine"
    type        = string
    default     = "~/.ssh/id_rsa.pub"
}

variable "source_image_reference" {
    description = "Source image reference for the virtual machine"
    type        = object({
        publisher = string
        offer     = string
        sku       = string
        version   = string
    })
    default = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
}