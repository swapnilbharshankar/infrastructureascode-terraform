# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "4.64.0"
#     }
#   }
# }

# provider "azurerm" {
#     features {
#         resource_group {
#         prevent_deletion_if_contains_resources = false
#         }
#     }
# }

# Fetching the public IP address of the Terraform executor.
data "http" "public_ip" {
  method = "GET"
  url    = "http://api.ipify.org?format=json"
}

resource "azurerm_virtual_network" "this" {
    name                = var.name
    address_space       = var.address_space
    location            = var.location
    resource_group_name = var.resource_group_name
    tags                = var.tags
}

resource "azurerm_subnet" "public" {
    depends_on = [ azurerm_virtual_network.this ]
    for_each = { for i in range(length(var.public)) : "${var.public[i].name}-${i}" => var.public[i] }
    name                 = "${var.name}-${each.value.name}"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.this.name
    address_prefixes     = each.value.cidr
    # dynamic "delegation" {
    #     for_each = each.value.delegation != null ? [each.value.delegation] : []
    #     content {
    #         name = delegation.value.name
    #         service_delegation {
    #             name    = delegation.value.service_delegation.name
    #             actions = delegation.value.service_delegation.actions
    #         }
    #     }
    # }
}

resource "azurerm_subnet" "private" {
    depends_on = [ azurerm_virtual_network.this ]
    for_each = { for i in range(length(var.private)) : "${var.private[i].name}-${i}" => var.private[i] }
    name                 = "${var.name}-${each.value.name}"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.this.name
    address_prefixes     = each.value.cidr
    # dynamic "delegation" {
    #     for_each = each.value.delegation != null ? [each.value.delegation] : []
    #     content {
    #         name = delegation.value.name
    #         service_delegation {
    #             name    = delegation.value.service_delegation.name
    #             actions = delegation.value.service_delegation.actions
    #         }
    #     }
    # }
}

resource "azurerm_route_table" "public" {
    location            = var.location
    name                = "${var.name}-public-route-table"
    resource_group_name = var.resource_group_name
    dynamic "route" {
        for_each = { for route in var.public_routes : route.name => route }
        content {
            name           = route.value.name
            address_prefix = route.value.address_prefix
            next_hop_type  = route.value.next_hop_type
            # next_hop_in_ip_address = lookup(route.name, "next_hop_ip_address", null)
        }
    }
}

resource "azurerm_route_table" "private" {
    location            = var.location
    name                = "${var.name}-private-route-table"
    resource_group_name = var.resource_group_name
    dynamic "route" {
        for_each = { for route in var.private_routes : route.name => route }  
        content {
            name           = route.value.name
            address_prefix = var.address_space[0]
            next_hop_type  = route.value.next_hop_type
            next_hop_in_ip_address = lookup(route.value, "next_hop_ip_address", null)
        }
    }
}

resource "azurerm_subnet_route_table_association" "public" {
    for_each = { for name, subnet in azurerm_subnet.public : name => subnet }
    subnet_id = each.value.id
    route_table_id = azurerm_route_table.public.id
}

resource "azurerm_subnet_route_table_association" "private" {
    for_each = { for name, subnet in azurerm_subnet.private : name => subnet }
    subnet_id = each.value.id
    route_table_id = azurerm_route_table.private.id
}


##
# resource "azurerm_network_security_group" "ssh" {
#   location            = var.location
#   name                = module.naming.network_security_group.name
#   resource_group_name = var.resource_group_name

#   security_rule {
#     access                     = "Allow"
#     destination_address_prefix = "*"
#     destination_port_range     = "22"
#     direction                  = "Inbound"
#     name                       = "test123"
#     priority                   = 100
#     protocol                   = "Tcp"
#     source_address_prefix      = jsondecode(data.http.public_ip.response_body).ip
#     source_port_range          = "*"
#   }
# }

# locals {
#     private_subnets = {
#         for i in range(length(var.private)) :
#         "${var.private[i].name}-${i}" => {
#             name             = "${var.name}-${var.private[i].name}"
#             address_prefixes = var.private[i].cidr
#             route_table = {
#                 id = azurerm_route_table.private.id
#             }
#         }
#     }
#     public_subnets = {
#         for i in range(length(var.public)) :
#         "${var.public[i].name}-${i}" => {
#             name             = "${var.name}-${var.public[i].name}"
#             address_prefixes = var.public[i].cidr
#             route_table = {
#                 id = azurerm_route_table.public.id
#             }
#             network_security_group = {
#                 id = azurerm_network_security_group.ssh.id
#             }
#         }
#     }
# }

# module "avm-res-network-virtualnetwork" {
#     source = "Azure/avm-res-network-virtualnetwork/azurerm"
#     version = "0.17.1"
    
#     address_space   = var.address_space
#     location        = var.location
#     name            = var.name
#     parent_id       = var.parent_id
#     subnets         = merge(local.public_subnets, local.private_subnets)
# }

# # public route table and route for internet access from public subnets
# resource "azurerm_route_table" "public" {
#     location            = var.location
#     name                = "${var.name}-public-route-table"
#     resource_group_name = var.resource_group_name
# }

# resource "azurerm_route" "public" {
#     address_prefix      = "0.0.0.0/0"
#     name                = "${var.name}-public-route"
#     next_hop_type       = "Internet"
#     resource_group_name = var.resource_group_name
#     route_table_name    = azurerm_route_table.public.name
# }

# # private route table and route for internet access from private subnets via NAT gateway
# resource "azurerm_route_table" "private" {
#     location            = var.location
#     name                = "${var.name}-private-route-table"
#     resource_group_name = var.resource_group_name
# }
