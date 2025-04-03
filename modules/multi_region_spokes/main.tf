module "spokes" {
  source = "../spokes"

  for_each = tomap({ for k,v in var.spoke : v.resource_group_name => v })
  
  network_manager_id = var.network_manager_id
  resource_group_name = each.value.resource_group_name
  region = var.region
  tags = var.tags
  vnets = each.value.vnets
  ipam_pool_id = var.ipam_pool_id
  hub_id = var.hub_id
  fw_private_ip = var.fw_private_ip
}
