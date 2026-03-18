# output "subnet_ids" {
#   description = "A map of subnet IDs created by the virtual network module."
#   value = {
#     for name, subnet in module.avm-res-network-virtualnetwork.subnets :
#     subnet.name => subnet.resource_id
#   }
# }
output "public_subnet_ids" {
    description = "A map of subnet IDs created by the virtual network module."
    value = {
        for name, subnet in azurerm_subnet.public :
        name => subnet.id
    }
}

output "private_subnets_ids" {
    description = "A map of private subnet IDs created by the virtual network module."
    value = {
        for name, subnet in azurerm_subnet.private :
        name => subnet.id
    }
}