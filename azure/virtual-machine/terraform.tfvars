vnet_name = "swapnil"
name = "swapnil-vm"
resource_group_name = "azure-free"
subnet_name = "public-subnet1"
create_public_ip_address = true
location = "centralindia"
size = "Standard_B2as_v2"
username = "adminuser"
public_key_path = "~/.ssh/id_ed25519.pub"
source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
}
