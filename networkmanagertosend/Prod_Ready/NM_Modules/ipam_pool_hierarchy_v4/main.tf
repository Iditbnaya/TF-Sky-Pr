locals {
  # These would be variables in your real implementation
  root_cidr = var.regional_ipam_pool_address_prefix

  ipam_pool_configs = {
    hub = {
      cidr        = var.regional_ipam_pool_hierarchy.hub_pool.address_prefix != null ? [var.regional_ipam_pool_hierarchy.hub_pool.address_prefix] : null
      subnet_mask = var.regional_ipam_pool_hierarchy.hub_pool.subnet_mask != null ? var.regional_ipam_pool_hierarchy.hub_pool.subnet_mask : null
      required    = true
    }
    spokes = {
      cidr        = var.regional_ipam_pool_hierarchy.spokes_pool.address_prefix != null ? [var.regional_ipam_pool_hierarchy.spokes_pool.address_prefix] : null
      subnet_mask = var.regional_ipam_pool_hierarchy.spokes_pool.subnet_mask != null ? var.regional_ipam_pool_hierarchy.spokes_pool.subnet_mask : null
      required    = true
    }
    monitoring = var.regional_ipam_pool_hierarchy.monitoring_pool != null ? {
      cidr        = var.regional_ipam_pool_hierarchy.monitoring_pool.address_prefix != null ? [var.regional_ipam_pool_hierarchy.monitoring_pool.address_prefix] : []
      subnet_mask = var.regional_ipam_pool_hierarchy.monitoring_pool.subnet_mask != null ? var.regional_ipam_pool_hierarchy.monitoring_pool.subnet_mask : 32
      required    = false
    } : {
      cidr = ["0.0.0.0/0"]
      subnet_mask = 32
      required = false
    }
  }

  include_monitoring = var.regional_ipam_pool_hierarchy.monitoring_pool != null ? true : false

  # Basic info about the root CIDR
  root_prefix = tonumber(split("/", local.root_cidr)[1])
  root_first_octet = tonumber(split(".", split("/", local.root_cidr)[0])[0])
  root_second_octet = tonumber(split(".", split("/", local.root_cidr)[0])[1])
  
  # Extract active pools
  active_pools = {
    for name, config in local.ipam_pool_configs :
    name => config 
    if config.required || (name == "monitoring" && local.include_monitoring)
  }
  
  # Hardcoded CIDRs
  hardcoded_cidrs = flatten([
    for name, config in local.active_pools :
    config.cidr != null ? config.cidr : []
  ])
  
  # Identify hardcoded CIDR blocks for each relevant subnet mask
  hardcoded_info = [
    for cidr in local.hardcoded_cidrs : {
      cidr = cidr
      first_octet = tonumber(split(".", split("/", cidr)[0])[0])
      second_octet = tonumber(split(".", split("/", cidr)[0])[1])
      mask = tonumber(split("/", cidr)[1])
    }
  ]
  
  # Pre-generate all possible /12 and /13 subnets within the root CIDR
  # For a /11 root, there are 2 possible /12 subnets and 4 possible /13 subnets
  all_possible_subnets = {
    "12" = [
      cidrsubnet(local.root_cidr, 1, 0),  # First /12 subnet in the root CIDR
      cidrsubnet(local.root_cidr, 1, 1)   # Second /12 subnet in the root CIDR
    ]
    "13" = [
      cidrsubnet(local.root_cidr, 2, 0),  # First /13 subnet in the root CIDR
      cidrsubnet(local.root_cidr, 2, 1),  # Second /13 subnet in the root CIDR
      cidrsubnet(local.root_cidr, 2, 2),  # Third /13 subnet in the root CIDR
      cidrsubnet(local.root_cidr, 2, 3)   # Fourth /13 subnet in the root CIDR
    ]
  }
  
  # Check if a subnet potentially overlaps with hardcoded CIDRs
  # This is a simplified check that works for most common cases
  subnet_overlap_info = {
    "12" = [
      for subnet in local.all_possible_subnets["12"] : {
        cidr = subnet
        first_octet = tonumber(split(".", split("/", subnet)[0])[0])
        second_octet = tonumber(split(".", split("/", subnet)[0])[1])
        # For a /12, the second octet range covers 16 values
        second_octet_range_start = tonumber(split(".", split("/", subnet)[0])[1])
        second_octet_range_end = tonumber(split(".", split("/", subnet)[0])[1]) + 15
        # Check if any hardcoded CIDR falls within this range
        overlaps = [
          for hinfo in local.hardcoded_info :
          hinfo.cidr if (
            hinfo.first_octet == tonumber(split(".", split("/", subnet)[0])[0]) && 
            hinfo.second_octet >= tonumber(split(".", split("/", subnet)[0])[1]) &&
            hinfo.second_octet <= tonumber(split(".", split("/", subnet)[0])[1]) + 15
          )
        ]
        has_overlap = length([
          for hinfo in local.hardcoded_info :
          hinfo.cidr if (
            hinfo.first_octet == tonumber(split(".", split("/", subnet)[0])[0]) && 
            hinfo.second_octet >= tonumber(split(".", split("/", subnet)[0])[1]) &&
            hinfo.second_octet <= tonumber(split(".", split("/", subnet)[0])[1]) + 15
          )
        ]) > 0
      }
    ]
    "13" = [
      for subnet in local.all_possible_subnets["13"] : {
        cidr = subnet
        first_octet = tonumber(split(".", split("/", subnet)[0])[0])
        second_octet = tonumber(split(".", split("/", subnet)[0])[1])
        # For a /13, the second octet range covers 8 values
        second_octet_range_start = tonumber(split(".", split("/", subnet)[0])[1])
        second_octet_range_end = tonumber(split(".", split("/", subnet)[0])[1]) + 7
        # Check if any hardcoded CIDR falls within this range
        overlaps = [
          for hinfo in local.hardcoded_info :
          hinfo.cidr if (
            hinfo.first_octet == tonumber(split(".", split("/", subnet)[0])[0]) && 
            hinfo.second_octet >= tonumber(split(".", split("/", subnet)[0])[1]) &&
            hinfo.second_octet <= tonumber(split(".", split("/", subnet)[0])[1]) + 7
          )
        ]
        has_overlap = length([
          for hinfo in local.hardcoded_info :
          hinfo.cidr if (
            hinfo.first_octet == tonumber(split(".", split("/", subnet)[0])[0]) && 
            hinfo.second_octet >= tonumber(split(".", split("/", subnet)[0])[1]) &&
            hinfo.second_octet <= tonumber(split(".", split("/", subnet)[0])[1]) + 7
          )
        ]) > 0
      }
    ]
  }
  
  # Filter non-overlapping subnets
  non_overlapping_subnets = {
    "12" = [
      for info in local.subnet_overlap_info["12"] :
      info.cidr if !info.has_overlap
    ]
    "13" = [
      for info in local.subnet_overlap_info["13"] :
      info.cidr if !info.has_overlap
    ]
  }
  
  # Allocate subnets for dynamic pools
  dynamic_allocations = {
    for name, config in local.active_pools : name => (
      config.cidr != null ? config.cidr : (
        # If this is the spokes pool
        name == "spokes" ? (
          # Try a single /12 block if available
          length(local.non_overlapping_subnets["12"]) > 0 ? 
          [local.non_overlapping_subnets["12"][0]] : (
            # Otherwise use two /13 blocks if available
            length(local.non_overlapping_subnets["13"]) >= 2 ?
            slice(local.non_overlapping_subnets["13"], 0, 2) : ["0.0.0.0/0"]
          )
        ) : ["0.0.0.0/0"]  # Default for other pools
      )
    )
  }
  
  # Final IPAM CIDR allocations
  ipam_cidrs = local.dynamic_allocations
}

module "hub_ipam_pool" {
  source = "../ipam_pool"
  
  region            = var.regional_ipam_pool_hierarchy.region
  name              = var.regional_ipam_pool_hierarchy.hub_pool.name
  
  address_prefixes  = local.ipam_cidrs.hub
  
  network_manager_id = var.network_manager_id
  parent_pool_name   = var.parent_ipam_pool_name
  is_child_pool      = var.regional_ipam_pool_hierarchy.hub_pool.is_child_pool != null ? var.regional_ipam_pool_hierarchy.hub_pool.is_child_pool : true
}

module "spokes_ipam_pools" {
  source = "../ipam_pool"
  
  region            = var.regional_ipam_pool_hierarchy.region
  name              = var.regional_ipam_pool_hierarchy.spokes_pool.name
  
  address_prefixes  = local.ipam_cidrs.spokes
  
  network_manager_id = var.network_manager_id
  parent_pool_name   = var.parent_ipam_pool_name
  is_child_pool      = var.regional_ipam_pool_hierarchy.spokes_pool.is_child_pool != null ? var.regional_ipam_pool_hierarchy.spokes_pool.is_child_pool : true
}

module "monitoring_ipam_pool" {
  count  = var.regional_ipam_pool_hierarchy.monitoring_pool != null ? 1 : 0
  source = "../ipam_pool"
  
  region            = var.regional_ipam_pool_hierarchy.region
  name              = var.regional_ipam_pool_hierarchy.monitoring_pool.name
  
  address_prefixes  = local.ipam_cidrs.monitoring
  
  network_manager_id = var.network_manager_id
  parent_pool_name   = var.parent_ipam_pool_name
  is_child_pool      = var.regional_ipam_pool_hierarchy.monitoring_pool.is_child_pool != null ? var.regional_ipam_pool_hierarchy.monitoring_pool.is_child_pool : true
} 