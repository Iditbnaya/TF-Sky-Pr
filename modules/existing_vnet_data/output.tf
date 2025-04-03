output "rg" {
  value = data.azurerm_resource_group.rg
}

output "vnet" {
  value = data.azurerm_virtual_network.vnet
}

output "fw" {
  value = data.azurerm_firewall.fw
}

output "vnet_id" {
  value = data.azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = data.azurerm_virtual_network.vnet.name
}

output "fw_private_ip" {
  value = data.azurerm_firewall.fw.ip_configuration[0].private_ip_address
}