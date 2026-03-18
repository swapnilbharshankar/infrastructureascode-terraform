variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
    default     = "azure-free"
}

variable "name" {
    description = "Name of the network"
    type        = string
    default     = "my-network"
}

variable "location" {
    description = "Location of the network"
    type        = string
    default     = "centralindia"
}

variable "parent_id" {
    description = "Parent resource ID for the network"
    type        = string
}

variable "address_space" {
    description = "Address space for the virtual network"
    type        = list(string)
    default     = ["10.0.0.0/16"]
}

variable "public" {
    description = "public subnets for the virtual network"
    type = list(object({ name = string, cidr = list(string) }))
    default = [
        {
            name = "public-subnet1"
            cidr = ["10.0.1.0/24"]
        },
        {
            name = "public-subnet2"
            cidr = ["10.0.2.0/24"]
        }
    ]
}

variable "public_routes" {
    description = "A list of routes to create in the public route table."
    type = list(object({
        name                = string
        address_prefix      = string
        next_hop_type       = string
        next_hop_ip_address = string
    }))
    default = []
  
}

variable "private" {
    description = "private subnets for the virtual network"
    type = list(object({ name = string, cidr = list(string) }))
    default = [
        {
            name = "private-subnet1"
            cidr = ["10.0.3.0/24"]
        },
        {
            name = "private-subnet2"
            cidr = ["10.0.4.0/24"]
        }
    ]
}

variable "private_routes" {
    description = "A list of routes to create in the private route table."
    type = list(object({
        name                = string
        # address_prefix      = string
        next_hop_type       = string
        next_hop_ip_address = string
    }))
    default = []
  
}

variable "tags" {
    description = "Tags for the virtual network"
    type = map(string)
    default = {}
}