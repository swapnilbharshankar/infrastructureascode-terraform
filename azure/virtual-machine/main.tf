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

module "vm_sku" {
    source  = "Azure/avm-utl-sku-finder/azapi"
    version = "0.3.0"

    location      = var.location
    cache_results = true
    vm_filters = {
        min_vcpus                      = 2
        max_vcpus                      = 2
        encryption_at_host_supported   = true
        accelerated_networking_enabled = true
        premium_io_supported           = true
        location_zone                  = random_integer.zone_index.result
    }

    depends_on = [random_integer.zone_index]
}

# data "azurerm_subnet" "subnet_data" {
#   name                 = var.subnet_name
#   virtual_network_name = var.vnet_name
#   resource_group_name  = var.resource_group_name
# }

module "avm-res-compute-virtualmachine" {
    source  = "Azure/avm-res-compute-virtualmachine/azurerm"
    version = "0.20.0"

    name                = var.name
    resource_group_name = var.resource_group_name
    location            = var.location
    zone                = random_integer.zone_index.result
    network_interfaces = {
        network_interface_1 = {
            name = module.naming.network_interface.name_unique
            ip_configurations = {
                ip_configuration_1 = {
                    name                          = "${module.naming.network_interface.name_unique}-ipconfig1"
                    public_ip_address_resource_id = var.subnet_id
                    private_ip_address_allocation = "Dynamic"
                    public_ip_address_allocation  = "Dynamic"
                }
            }
        }
    }
    account_credentials = {
        admin_credentials = {
             username = var.username
             public_key_path = var.public_key_path
        }
    }
    admin_username      = var.username
    os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference = {
        publisher = var.source_image_reference.publisher
        offer     = var.source_image_reference.offer
        sku       = var.source_image_reference.sku
        version   = var.source_image_reference.version
    }
}

# resource "random_string" "unique_suffix" {
#   length  = 6
#   special = false
#   upper   = false
# }

# data "azurerm_subnet" "subnet_data" {
#   name                 = var.subnet_name
#   virtual_network_name = var.vnet_name
#   resource_group_name  = var.resource_group_name
# }

# resource "azurerm_network_interface" "nic" {
#     name                = "${var.name}-nic-${random_string.unique_suffix.result}"
#     location            = var.location
#     resource_group_name = var.resource_group_name

#     ip_configuration {
#         name                          = "internal"
#         subnet_id                     = data.azurerm_subnet.subnet_data.id
#         private_ip_address_allocation = "Dynamic"
#     }
# }

# resource "azurerm_linux_virtual_machine" "example" {
#     name                = var.name
#     resource_group_name = var.resource_group_name
#     location            = var.location
#     size                = var.size
#     admin_username      = var.username
#     network_interface_ids = [
#         azurerm_network_interface.nic.id,
#     ]

#     admin_ssh_key {
#         username   = var.username
#         public_key = file(var.public_key_path)
#     }

#     os_disk {
#         caching              = "ReadWrite"
#         storage_account_type = "Standard_LRS"
#     }

#     source_image_reference {
#         publisher = var.source_image_reference.publisher
#         offer     = var.source_image_reference.offer
#         sku       = var.source_image_reference.sku
#         version   = var.source_image_reference.version
#     }
# }