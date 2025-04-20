module "subnet_name" {
  source = "../naming"

  resource_type = "subnet"
  name = "${var.vnet_name}-${var.name}"
  region = var.region
}

resource "azapi_resource" "subnets" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  name      = var.is_bastion_subnet ? "AzureBastionSubnet" : (var.is_firewall_subnet ? "AzureFirewallSubnet" : module.subnet_name.standard_name)
  parent_id = var.virtual_network_id
  
  body      = {
    properties = {
      ipamPoolPrefixAllocations = [
        {
          numberOfIpAddresses = tostring(pow(2, 32 - var.subnet_mask))
          pool = {
            id = var.ipam_pool_id
          }
        }
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

module "fw" {
  source = "../firewall"
  count = var.is_firewall_subnet ? 1 : 0

  name = "${var.name}"
  region = var.region
  resource_group_name = var.resource_group_name
  subnet_id = azapi_resource.subnets.id
}

module "bastion" {
  source = "../bastion"
  count = var.is_bastion_subnet ? 1 : 0

  name = "${var.name}"
  region = var.region
  resource_group_name = var.resource_group_name
  subnet_id = azapi_resource.subnets.id
}
