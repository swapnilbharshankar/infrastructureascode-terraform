# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

# Fetching the public IP address of the Terraform executor.
data "http" "public_ip" {
  method = "GET"
  url    = "http://api.ipify.org?format=json"
}

resource "azurerm_network_security_group" "ssh" {
  location            = var.location
  name                = module.naming.network_security_group.name
  resource_group_name = var.resource_group_name

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    direction                  = "Inbound"
    name                       = "test123"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = jsondecode(data.http.public_ip.response_body).ip
    source_port_range          = "*"
  }
}

locals {
    private_subnets = {
        for i in range(length(var.private)) :
        "${var.private[i].name}-${i}" => {
            name             = "${var.name}-${var.private[i].name}"
            address_prefixes = var.private[i].cidr
            route_table = {
                id = azurerm_route_table.private.id
            }
        }
    }
    public_subnets = {
        for i in range(length(var.public)) :
        "${var.public[i].name}-${i}" => {
            name             = "${var.name}-${var.public[i].name}"
            address_prefixes = var.public[i].cidr
            route_table = {
                id = azurerm_route_table.public.id
            }
            azurerm_network_security_group = {
                id = azurerm_network_security_group.ssh.id
            }
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

# public route table and route for internet access from public subnets
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

# private route table and route for internet access from private subnets via NAT gateway
resource "azurerm_route_table" "private" {
    location            = var.location
    name                = "${var.name}-private-route-table"
    resource_group_name = var.resource_group_name
}
