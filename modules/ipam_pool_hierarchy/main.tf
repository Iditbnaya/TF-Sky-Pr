module "parent_ipam_pool" {
  source = "../ipam_pool"

  name = var.name
  region = var.region
  tags = var.tags

  address_prefixes = var.address_prefixes
  network_manager_id = var.network_manager_id
}

module "hub_ipam_pool" {
  source = "../ipam_pool"

  name = var.hub_pool.name
  region = var.region
  tags = var.tags

  address_prefixes = var.hub_pool.address_prefixes
  network_manager_id = var.network_manager_id
  parent_pool_name = module.parent_ipam_pool.name
  is_child_pool = true

  depends_on = [module.parent_ipam_pool.creation_time]
}

module "spoke_ipam_pools" {
  source = "../ipam_pool"

  region = var.region
  tags = var.tags
  name = var.spoke_pools.name
  address_prefixes = var.spoke_pools.address_prefixes
  network_manager_id = var.network_manager_id
  parent_pool_name = module.parent_ipam_pool.name
  is_child_pool = true

  depends_on = [module.parent_ipam_pool.creation_time]
}

module "monitoring_ipam_pool" {
  source = "../ipam_pool"

  region = var.region
  tags = var.tags
  name = var.monitoring_pool.name
  address_prefixes = var.monitoring_pool.address_prefixes
  network_manager_id = var.network_manager_id
  parent_pool_name = module.parent_ipam_pool.name
  is_child_pool = true

  depends_on = [module.parent_ipam_pool.creation_time]
}