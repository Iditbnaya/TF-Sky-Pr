output "id" {
  description = "The ID of the network rule collection"
  value       = azurerm_firewall_network_rule_collection.this.id
}

output "name" {
  description = "The name of the network rule collection"
  value       = azurerm_firewall_network_rule_collection.this.name
}

output "azure_firewall_name" {
  description = "The name of the Azure Firewall"
  value       = azurerm_firewall_network_rule_collection.this.azure_firewall_name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_firewall_network_rule_collection.this.resource_group_name
}

output "priority" {
  description = "The priority of the network rule collection"
  value       = azurerm_firewall_network_rule_collection.this.priority
}

output "action" {
  description = "The action of the network rule collection"
  value       = azurerm_firewall_network_rule_collection.this.action
}
