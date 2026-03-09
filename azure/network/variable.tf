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

variable "subnets" {
    description = "Subnets for the virtual network"
    type        = map(object({
        name             = string
        address_prefixes = list(string)
    }))
    default     = {
        "subnet1" = {
            name             = "subnet1"
            address_prefixes = ["10.0.0.0/24"]
        }
        "subnet2" = {
            name             = "subnet2"
            address_prefixes = ["10.0.1.0/24"]
        }
    }
}