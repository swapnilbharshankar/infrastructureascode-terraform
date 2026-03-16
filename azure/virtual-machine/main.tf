terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.5.0"

  availability_zones_filter = true
}

resource "random_integer" "region_index" {
    max = length(module.regions.regions_by_name) - 1
    min = 0
}

resource "random_integer" "zone_index" {
    max = length(module.regions.regions_by_name[var.location].zones)
    min = 1
}

data "azurerm_subnet" "subnet_data" {
    name                 = "${var.vnet_name}-${var.subnet_name}"
    virtual_network_name = var.vnet_name
    resource_group_name  = var.resource_group_name
}

module "avm-res-compute-virtualmachine" {
    source  = "Azure/avm-res-compute-virtualmachine/azurerm"
    version = "0.20.0"

    for_each = { for id, virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine }
    name                = each.value.name
    resource_group_name = var.resource_group_name
    location            = var.location
    zone                = random_integer.zone_index.result
    network_interfaces = {
        network_interface_1 = {
            name = module.naming.network_interface.name_unique
            ip_configurations = {
                ip_configuration_1 = {
                    name                            = "${module.naming.network_interface.name_unique}-ipconfig1"
                    private_ip_subnet_resource_id   = data.azurerm_subnet.subnet_data.id
                    private_ip_address_allocation   = "Dynamic"
                    create_public_ip_address        = each.value.create_public_ip_address
                    public_ip_address_name          = "${module.naming.network_interface.name_unique}-publicip"
                }
            }
        }
    }
    admin_username = each.value.username
    account_credentials = {
        admin_credentials = {
            username = each.value.username
            public_key = file(each.value.public_key_path)
        }
    }
    os_type = "Linux"
    sku_size = each.value.size
    os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference = {
        publisher = each.value.source_image_reference.publisher
        offer     = each.value.source_image_reference.offer
        sku       = each.value.source_image_reference.sku
        version   = each.value.source_image_reference.version
    }
    encryption_at_host_enabled = false
}
