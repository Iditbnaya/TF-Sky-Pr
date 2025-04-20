output "id" {
  description = "The ID of the network manager"
  value       = azurerm_network_manager.this.id
}

output "name" {
  description = "The name of the network manager"
  value       = azurerm_network_manager.this.name
}

output "creation_time" {
  description = "The creation time of the network manager"
  value       = time_sleep.wait_for_network_manager.id
}
