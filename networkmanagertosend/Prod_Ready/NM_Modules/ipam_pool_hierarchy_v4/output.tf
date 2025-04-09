output "spokes_ipam_pool_id" {
  value = module.spokes_ipam_pools.id
}

output "hub_ipam_pool_id" {
  value = module.hub_ipam_pool.id
}

output "monitoring_ipam_pool_id" {
  value = var.regional_ipam_pool_hierarchy.monitoring_pool != null ? module.monitoring_ipam_pool[0].id : null
} 