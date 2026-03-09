module "avm-res-network-virtualnetwork" {
    source = "Azure/avm-res-network-virtualnetwork/azurerm"
    version = "0.17.1"
    
    address_space   = var.address_space
    location        = var.location
    name            = var.name
    parent_id       = var.parent_id
    subnets         = var.subnets
}