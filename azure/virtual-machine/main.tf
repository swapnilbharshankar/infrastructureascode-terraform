resource "random_string" "unique_suffix" {
  length  = 6
  special = false
  upper   = false
}

data "azurerm_subnet" "subnet_data" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_network_interface" "nic" {
    name                = "${var.name}-nic-${random_string.unique_suffix.result}"
    location            = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = data.azurerm_subnet.subnet_data.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "example" {
    name                = var.name
    resource_group_name = var.resource_group_name
    location            = var.location
    size                = var.size
    admin_username      = var.username
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]

    admin_ssh_key {
        username   = var.username
        public_key = file(var.public_key_path)
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = var.source_image_reference.publisher
        offer     = var.source_image_reference.offer
        sku       = var.source_image_reference.sku
        version   = var.source_image_reference.version
    }
}