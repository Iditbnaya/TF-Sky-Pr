locals {
  flattened_network_group_environments_existing_hubs = flatten([
    for k, v in var.existing_hubs_info : [
      for env in var.network_group_environments : {
        key = "${v.region}-${env}"
        region = v.region
        environment = env
        vnet_id = v.vnet_id
        fw_private_ip = v.fw_private_ip
        name = v.name
      }
    ]
  ])
}

module "nm_rg" {
  source = "../../NM_Modules/resource_group"
  name = var.network_manager_config.name
  region = var.network_manager_config.region
  tags = var.tags
}

# Create the Network Manager
module "network_manager" {
  source = "../../NM_Modules/network_manager"
  name = var.network_manager_config.name
  region = var.network_manager_config.region
  resource_group_name = module.nm_rg.name
  scope_accesses = var.network_manager_config.scope_accesses
  subscriptions = var.network_manager_config.subscriptions
  management_groups = var.network_manager_config.management_groups

  tags = var.tags
  depends_on = [module.nm_rg]
}

# Create the Parent IPAM Pool
module "parent_ipam_pool" {
  source = "../../NM_Modules/ipam_pool"
  name = var.parent_ipam_pool_config.name
  region = var.network_manager_config.region
  address_prefixes = ["${var.parent_ipam_pool_config.address_prefix}/${var.parent_ipam_pool_config.address_subnet_mask}"]
  network_manager_id = module.network_manager.id
  tags = var.tags

  depends_on = [module.network_manager]
}

# Create the Regional Child IPAM Pools for each region
module "region_child_ipam_pools" {
  source = "../../NM_Modules/ipam_pool"

  for_each = {for idx, region in var.regions : region => {
    name = region
    region = region
    index = idx
  }}
  name = each.value.name
  region = each.value.region
  address_prefixes = [cidrsubnet(module.parent_ipam_pool.address_prefixes[0], 
    (var.regional_subnet_masks - var.parent_ipam_pool_config.address_subnet_mask), 
    each.value.index)]
  network_manager_id = module.network_manager.id
  tags = var.tags

  # Make this a child pool
  is_child_pool = true
  parent_pool_name = module.parent_ipam_pool.name

  depends_on = [module.parent_ipam_pool]
}

# Creates the Regional IPAM Pool Hierarchies
module "ipam_pool_hierarchy" {
  source = "../../NM_Modules/ipam_pool_hierarchy_v4"

  for_each = {for k, v in var.ipam_pool_hierarchy : v.region => v}
  regional_ipam_pool_hierarchy = each.value
  parent_ipam_pool_name = module.region_child_ipam_pools[each.value.region].name
  parent_ipam_pool_address_prefix = module.parent_ipam_pool.address_prefixes[0]
  regional_ipam_pool_address_prefix = module.region_child_ipam_pools[each.value.region].address_prefixes[0]
  network_manager_id = module.network_manager.id

  depends_on = [module.region_child_ipam_pools]
}

module "network_group_hierarchy" {
  source = "../../NM_Modules/network_group_hierarchy"

  for_each = {for idx, region in var.regions : region => {
    name = region
    region = region
    index = idx
  }}

  network_manager_id = module.network_manager.id
  regions = each.value.region
  name = "regional-ng"
  environments = var.network_group_environments
}

module "existing_hubs_connectivity_config" {
  source = "../../NM_Modules/connectivity_config_deployment"

  for_each = {for k, v in var.existing_hubs_info : v.region => v}
  network_manager_id = module.network_manager.id
  region = each.value.region
  hub_id = each.value.vnet_id
  name = "HubAndSpoke-${each.value.region}"
  network_group_ids = module.network_group_hierarchy[each.value.region].network_group_ids
  environments = var.network_group_environments
}

module "existing_hubs_user_defined_routes" {
  source = "../../NM_Modules/network_manager_routing"

  for_each = {for k, v in local.flattened_network_group_environments_existing_hubs : v.key => v}
  network_manager_id = module.network_manager.id
  region = each.value.region
  fw_private_ip = each.value.fw_private_ip
  name = "HubAndSpoke-${each.value.key}"
  network_group_id = module.network_group_hierarchy[each.value.region].network_group_ids[each.value.environment]
  resource_group_name = module.nm_rg.name
}

