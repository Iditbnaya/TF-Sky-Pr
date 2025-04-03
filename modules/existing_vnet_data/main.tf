data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_firewall" "fw" {
  name                = var.fw_name
  resource_group_name = var.resource_group_name
}