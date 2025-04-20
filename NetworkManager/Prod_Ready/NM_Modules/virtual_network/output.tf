output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azapi_resource.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azapi_resource.vnet.name
}

output "fw_private_ip" {
  description = "The private IP address of the firewall as a string"
  value       = try(values({for subnet in module.subnets : subnet.subnet_name => subnet.fw_private_ip if subnet.fw_private_ip != null})[0], null)
}

output "fw_name" {
  description = "The name of the firewall"
  value       = try(values({for subnet in module.subnets : subnet.subnet_name => subnet.fw_name if subnet.fw_name != null})[0], null)
}
