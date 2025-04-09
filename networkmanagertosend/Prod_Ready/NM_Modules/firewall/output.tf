output "firewall_id" {
  value = azurerm_firewall.firewall.id
}

output "firewall_public_ip" {
  value = azurerm_public_ip.firewall_public_ip.ip_address
}

output "fw_private_ip" {
  description = "The IP address of the firewall"
  value       = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

output "fw_name" {
  description = "The name of the firewall"
  value       = azurerm_firewall.firewall.name
}

