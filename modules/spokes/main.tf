module "spoke_resource_group" {
  source = "../resource_group"

  name = var.resource_group_name
  region = var.region
  tags = var.tags
}

module "spoke_vnets" {
  source = "../virtual_network"

  for_each = tomap({ for k,v in var.vnets : v.name => v })

  name = each.value.name
  region = var.region
  tags = var.tags
  resource_group_name = module.spoke_resource_group.name
  resource_group_id = module.spoke_resource_group.id
  subnet_mask = each.value.subnet_mask
  subnets = each.value.subnets
  ipam_pool_id = var.ipam_pool_id
}


module "spoke_ng_name" {
  source = "../naming"

  resource_type = "network_group"
  name = var.resource_group_name
  region = var.region
}

resource "azurerm_network_manager_network_group" "network_group" {
  name               = module.spoke_ng_name.standard_name
  network_manager_id = var.network_manager_id
}

resource "azurerm_network_manager_static_member" "network_group_member" {
  for_each = tomap({ for k,v in var.vnets : v.name => v })
  
  name                      = each.value.name
  network_group_id          = azurerm_network_manager_network_group.network_group.id
  target_virtual_network_id = module.spoke_vnets[each.key].vnet_id

  depends_on = [azurerm_network_manager_network_group.network_group, module.spoke_vnets]
}

module "connectivity_config" {
  source = "../connectivity_config"
  count = var.hub_id != null ? 1 : 0

  network_manager_id = var.network_manager_id
  region = var.region
  hub_id = var.hub_id
  name = "${var.resource_group_name}"
  network_group_id = azurerm_network_manager_network_group.network_group.id

  depends_on = [azurerm_network_manager_static_member.network_group_member]
}

module "user_defined_routes" {
  source = "../network_manager_routing"
  count = var.fw_private_ip != null ? 1 : 0

  network_manager_id = var.network_manager_id
  region = var.region
  resource_group_name = module.spoke_resource_group.name
  fw_private_ip = var.fw_private_ip
  name = "${var.resource_group_name}"
  network_group_id = azurerm_network_manager_network_group.network_group.id

  depends_on = [azurerm_network_manager_static_member.network_group_member]
}
