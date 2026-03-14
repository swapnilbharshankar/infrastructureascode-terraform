locals {
    public_subnet = merge(
        var.subnets.public,
        {
            route_table = {
                id = azurerm_route_table.public.id
            }
        }
    )
    private_subnet = var.subnets.private
}

module "avm-res-network-virtualnetwork" {
    source = "Azure/avm-res-network-virtualnetwork/azurerm"
    version = "0.17.1"
    
    address_space   = var.address_space
    location        = var.location
    name            = var.name
    parent_id       = var.parent_id
    subnets         = {
        public = local.public_subnet
        private = local.private_subnet
    }
}


resource "azurerm_route_table" "public" {
    location            = var.location
    name                = "${var.name}-public-route-table"
    resource_group_name = var.resource_group_name
}

resource "azurerm_route" "public" {
    address_prefix      = "0.0.0/0"
    name                = "${var.name}-public-route"
    next_hop_type       = "Internet"
    resource_group_name = var.resource_group_name
    route_table_name    = azurerm_route_table.public.name
}
