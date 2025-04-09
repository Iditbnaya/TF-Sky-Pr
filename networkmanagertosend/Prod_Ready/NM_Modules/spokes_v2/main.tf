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

resource "azurerm_network_manager_static_member" "network_group_member" {
  for_each = tomap({ for k,v in var.vnets : v.name => v })
  
  provider = azurerm.network_manager

  name                      = each.value.name
  network_group_id          = var.network_group_id
  target_virtual_network_id = module.spoke_vnets[each.key].vnet_id

  depends_on = [module.spoke_vnets]
}