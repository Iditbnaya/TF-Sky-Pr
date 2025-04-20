output "network_manager_id" {
  value = module.network_manager.id
}

output "network_groups" {
  value = {for idx, region in var.regions : region => module.network_group_hierarchy[region].network_group_ids}
}

output "spoke_ipam_pool_ids" {
  value = {for idx, region in var.regions : region => module.ipam_pool_hierarchy[region].spokes_ipam_pool_id}
}
