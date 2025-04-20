module "connectivity_configs" {
  source = "../connectivity_config_v2"

  for_each = {for idx, v in var.environments : v => {
    environment = v
  }}

  network_manager_id = var.network_manager_id
  hub_id = var.hub_id
  network_group_id = var.network_group_ids[each.value.environment]
  name = "${var.name}-${each.value.environment}"
  region = var.region
}

module "connectivity_config_deployment_name" {
  source = "../naming"

  resource_type = "config_deployment"
  name          = var.name
  region        = var.region
}

resource "azurerm_network_manager_deployment" "connectivity_config_deployment" {
  network_manager_id = var.network_manager_id
  location = var.region
  scope_access = "Connectivity"
  configuration_ids = [for config in module.connectivity_configs : config.configuration_id]
}