output "network_group_id" {
  description = "The ID of the network group"
  value       = azurerm_network_manager_network_group.network_group.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.resource_group_name
}

output "region" {
  description = "The region of the resource group"
  value       = var.region
}
