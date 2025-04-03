module "connectivity_config_name" {
  source = "../naming"

  resource_type = "connectivity_config"
  name          = var.name
  region        = var.region
}


resource "azurerm_network_manager_connectivity_configuration" "connectivity_config" {
  name = module.connectivity_config_name.standard_name
  network_manager_id = var.network_manager_id
  connectivity_topology = var.connectivity_topology
  applies_to_group {
    group_connectivity = var.group_connectivity
    network_group_id = var.network_group_id
  }

  hub {
    resource_id = var.hub_id
    resource_type = "Microsoft.Network/virtualNetworks"
  }
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
  configuration_ids = [azurerm_network_manager_connectivity_configuration.connectivity_config.id]
}

