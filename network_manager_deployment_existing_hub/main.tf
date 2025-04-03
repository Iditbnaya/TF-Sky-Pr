module "existing_hubs_data" {
  source = "../modules/existing_vnet_data"

  for_each = tomap({ for k,v in var.existing_hubs : v.region => v })
  resource_group_name = each.value.resource_group_name
  vnet_name = each.value.vnet_name
  fw_name = each.value.fw_name
}

# Create the Network Manager Configuration 
module "nm_resource_group" {
  source = "../modules/resource_group"

  name   = var.network_manager_resource_group_name
  region = var.region
  tags   = var.tags
}

module "network_manager" {
  source = "../modules/network_manager"

  name = var.network_manager.name
  region = var.region
  tags = var.tags

  resource_group_name = module.nm_resource_group.name

  scope_accesses = var.network_manager.scope_accesses
  management_groups = var.network_manager.management_groups
  subscriptions = var.network_manager.subscriptions

  depends_on = [module.nm_resource_group.standard_name]
}

module "ipam_pool_hierarchy" {
  source = "../modules/ipam_pool_hierarchy"

  for_each = tomap({ for k,v in var.ipam_pools : v.region => v })
  name = each.value.name
  region = each.value.region
  tags = var.tags
  network_manager_id = module.network_manager.id
  address_prefixes = each.value.address_prefixes
  hub_pool = each.value.hub_pool
  spoke_pools = each.value.spoke_pools
  monitoring_pool = each.value.monitoring_pool

  depends_on = [module.network_manager.creation_time]
}