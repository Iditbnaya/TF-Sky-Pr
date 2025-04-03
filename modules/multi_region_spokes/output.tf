output "network_group_ids" {
  description = "The network group ids"
  value       = { for k,v in module.spokes : k => v.network_group_id }
}

output "spokes" {
  description = "The spokes"
  value       = module.spokes
}

output "region" {
  description = "The region"
  value       = var.region
}
