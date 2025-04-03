output "parent_pool_id" {
  description = "The ID of the parent IPAM pool"
  value = module.parent_ipam_pool.id
}

output "hub_pool_id" {
  description = "The ID of the hub IPAM pool"
  value = module.hub_ipam_pool.id
}

output "spoke_pool_ids" {
  description = "The IDs of the spoke IPAM pools"
  value = module.spoke_ipam_pools.id
}

output "hub_pool_creation_time" {
  description = "The creation time of the hub IPAM pool"
  value = module.hub_ipam_pool.creation_time
}

output "spoke_pool_creation_times" {
  description = "The creation times of the spoke IPAM pools"
  value = module.spoke_ipam_pools.creation_time
}
