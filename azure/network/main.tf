module "avm-res-network-virtualnetwork" {
    source = "Azure/avm-res-network-virtualnetwork/azurerm"
    version = "0.17.1"
    
    address_space = var.address_space
    location      = var.location
    name          = var.name
    parent_id     = var.parent_id
    subnets = {
        "subnet1" = {
            name             = "${var.name}-private-subnet1"
            address_prefixes = ["10.0.0.0/24"]
        }
        "subnet2" = {
            name             = "${var.name}-private-subnet2"
            address_prefixes = ["10.0.1.0/24"]
        }
    }
}