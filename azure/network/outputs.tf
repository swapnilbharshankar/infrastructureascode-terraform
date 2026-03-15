output "subnet_ids" {
  description = "A map of subnet IDs created by the virtual network module."
  value = {
    for name, subnet in module.your_vnet_module_name.subnets :
    name => subnet.resource_id
  }
}