output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.resource_group_name
}

output "region" {
  description = "The region of the resource group"
  value       = var.region
}

output "vnet_names" {
  description = "The names of the vnets"
  value       = {for k, v in module.spoke_vnets : v.vnet_name => v.vnet_id}
}


