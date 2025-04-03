module "routing_config_name" {
  source = "../naming"

  resource_type = "routing_config"
  name          = var.name
  region        = var.region
}


resource "azapi_resource" "network_manager_routing_config" {
  type      = "Microsoft.Network/networkManagers/routingConfigurations@2024-05-01"
  name      = module.routing_config_name.standard_name
  parent_id = var.network_manager_id

  body = {
    properties = {
    }
  }
}

module "routing_config_rule_collection_name" {
  source = "../naming"

  resource_type = "routing_config_rule_collection"
  name          = var.name
  region        = var.region
}

resource "azapi_resource" "network_manager_routing_config_rule_collection" {
  type      = "Microsoft.Network/networkManagers/routingConfigurations/ruleCollections@2024-05-01"
  name      = module.routing_config_rule_collection_name.standard_name
  parent_id = azapi_resource.network_manager_routing_config.id

  body = {
    properties = {
      appliesTo = [
        {
          networkGroupId = var.network_group_id
        }
      ]
    }
  }
}

resource "azapi_resource" "network_manager_routing_config_rule_collection_rule" {
  type      = "Microsoft.Network/networkManagers/routingConfigurations/ruleCollections/rules@2024-05-01"
  name      = module.routing_config_rule_collection_name.standard_name
  parent_id = azapi_resource.network_manager_routing_config_rule_collection.id

  body = {
    properties = {
        destination = {
            type = "AddressPrefix"
            destinationAddress = "0.0.0.0/0"
        }
        nextHop = {
            nextHopType = "VirtualAppliance"
            nextHopAddress = var.fw_private_ip
        }
    }
  }
}
