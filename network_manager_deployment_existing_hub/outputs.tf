output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.nm_resource_group.id
}

output "fw_private_ip" {
  description = "The private IP address of the firewall as a string"
  value       = {
    for region, fw in module.existing_hubs_data : region => fw.fw.ip_configuration[0].private_ip_address
  }
}

output "network_manager_id" {
  description = "ID of the network manager"
  value       = module.network_manager.id
}

output "network_manager_name" {
  description = "Name of the network manager"
  value       = module.network_manager.name
}

output "ipam_pools" {
  description = "IPAM pool IDs by region"
  value = {
    for region, pool in module.ipam_pool_hierarchy : region => {
      parent_pool_id = pool.parent_pool_id
      hub_pool_id    = pool.hub_pool_id
      spoke_pool_ids = pool.spoke_pool_ids
    }
  }
}

output "hub_vnet_ids" {
  description = "The IDs of the hub virtual networks"
  value = {
    for region, hub in module.existing_hubs_data : region => hub.vnet_id
  }
}

output "hub_vnet_names" {
  description = "The names of the hub virtual networks"
  value = {
    for region, hub in module.existing_hubs_data : region => hub.vnet_name
  }
}