locals {
    public_subnets = {
        for i in range(length(var.private)) :
        "${var.private[i].name}-${i}" => {
            name             = var.private[i].name
            address_prefixes = var.private[i].cidr
            route_table_id   = azurerm_route_table.public.id
        }
    }
    private_subnets = {
        for i in range(length(var.public)) :
        "${var.public[i].name}-${i}" => {
            name             = var.public[i].name
            address_prefixes = var.public[i].cidr
        }
    }
}

module "avm-res-network-virtualnetwork" {
    source = "Azure/avm-res-network-virtualnetwork/azurerm"
    version = "0.17.1"
    
    address_space   = var.address_space
    location        = var.location
    name            = var.name
    parent_id       = var.parent_id
    subnets         = merge(local.public_subnets, local.private_subnets)
}


resource "azurerm_route_table" "public" {
    location            = var.location
    name                = "${var.name}-public-route-table"
    resource_group_name = var.resource_group_name
}

resource "azurerm_route" "public" {
    address_prefix      = "0.0.0.0/0"
    name                = "${var.name}-public-route"
    next_hop_type       = "Internet"
    resource_group_name = var.resource_group_name
    route_table_name    = azurerm_route_table.public.name
}
