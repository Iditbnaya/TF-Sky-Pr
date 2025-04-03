module "user_defined_routes" {
  source = "../network_manager_routing"

  for_each = tomap({ for k,v in var.spokes : v.resource_group_name => v })

  network_manager_id = var.network_manager_id
  region = each.value.region
  fw_private_ip = var.fw_private_ip
  name = "udr"
  network_group_id = each.value.network_group_id
  resource_group_name = var.nm_resource_group_name
}

module "connectivity_config" {
  source = "../connectivity_config"

  for_each = tomap({ for k,v in var.spokes : v.resource_group_name => v })
  name = var.connectivity_config.name
  network_manager_id = var.network_manager_id
  region = each.value.region
  hub_id = var.existing_hub_vnet_id
  network_group_id = each.value.network_group_id

  depends_on = [var.network_manager_id, var.existing_hub_vnet_id]
}