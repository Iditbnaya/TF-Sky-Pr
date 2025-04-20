locals {
    # Get the regional pool address prefix
    regional_cidr = var.regional_ipam_pool_address_prefix
    regional_mask = tonumber(split("/", local.regional_cidr)[1])
    
    # Determine the pool subnet masks
    hub_mask = var.regional_ipam_pool_hierarchy.hub_pool.subnet_mask != null ? var.regional_ipam_pool_hierarchy.hub_pool.subnet_mask : 32
    spokes_mask = var.regional_ipam_pool_hierarchy.spokes_pool.subnet_mask != null ? var.regional_ipam_pool_hierarchy.spokes_pool.subnet_mask : 32
    monitoring_mask = var.regional_ipam_pool_hierarchy.monitoring_pool != null ? var.regional_ipam_pool_hierarchy.monitoring_pool.subnet_mask : 32
    
    # Find the smallest subnet mask (largest network size) needed
    min_mask = min(local.hub_mask, local.spokes_mask, var.regional_ipam_pool_hierarchy.monitoring_pool != null ? local.monitoring_mask : 32)
    
    # Determine the size of the largest network in bits from the regional prefix
    largest_network_bits = local.min_mask - local.regional_mask
    
    # Calculate how many networks of largest size we can fit in the regional prefix
    # This is 2^bits where bits is the difference between regional and largest network
    max_networks_of_largest_size = pow(2, local.largest_network_bits)
    
    # Determine how many bits we need to represent our three pool types (hub, spokes, monitoring)
    # We need at least 2 bits (for 3-4 pools), 3 bits would handle up to 8 pools
    bits_needed_for_pools = local.max_networks_of_largest_size >= 4 ? 2 : 3
    
    # Create proper sizings for each pool
    # First, allocate exact subnet sizes for each pool type
    hub_cidr = cidrsubnet(local.regional_cidr, local.hub_mask - local.regional_mask, 0)
    spokes_cidr = cidrsubnet(local.regional_cidr, local.spokes_mask - local.regional_mask, 1)  
    monitoring_cidr = var.regional_ipam_pool_hierarchy.monitoring_pool != null ? cidrsubnet(local.regional_cidr, local.monitoring_mask - local.regional_mask, 2) : ""
}

module "hub_ipam_pool" {
    source = "../ipam_pool"
    region = var.regional_ipam_pool_hierarchy.region
    name = var.regional_ipam_pool_hierarchy.hub_pool.name
    
    # Use the exact subnet mask from the config
    address_prefixes = [(var.regional_ipam_pool_hierarchy.hub_pool.address_prefix != null) ? var.regional_ipam_pool_hierarchy.hub_pool.address_prefix : local.hub_cidr]
    
    network_manager_id = var.network_manager_id
    parent_pool_name = var.parent_ipam_pool_name
    is_child_pool = var.regional_ipam_pool_hierarchy.hub_pool.is_child_pool
}

module "spokes_ipam_pools" {
    source = "../ipam_pool"
    region = var.regional_ipam_pool_hierarchy.region
    name = var.regional_ipam_pool_hierarchy.spokes_pool.name
    
    # Use the exact subnet mask from the config
    address_prefixes = [(var.regional_ipam_pool_hierarchy.spokes_pool.address_prefix != null) ? var.regional_ipam_pool_hierarchy.spokes_pool.address_prefix : local.spokes_cidr]
    
    network_manager_id = var.network_manager_id
    parent_pool_name = var.parent_ipam_pool_name
    is_child_pool = var.regional_ipam_pool_hierarchy.spokes_pool.is_child_pool
}

module "monitoring_ipam_pool" {
    count = var.regional_ipam_pool_hierarchy.monitoring_pool != null ? 1 : 0
    source = "../ipam_pool"
    region = var.regional_ipam_pool_hierarchy.region
    name = var.regional_ipam_pool_hierarchy.monitoring_pool.name
    
    # Use the exact subnet mask from the config
    address_prefixes = [(var.regional_ipam_pool_hierarchy.monitoring_pool.address_prefix != null) ? var.regional_ipam_pool_hierarchy.monitoring_pool.address_prefix : local.monitoring_cidr]
    
    network_manager_id = var.network_manager_id
    parent_pool_name = var.parent_ipam_pool_name
    is_child_pool = var.regional_ipam_pool_hierarchy.monitoring_pool.is_child_pool
}
