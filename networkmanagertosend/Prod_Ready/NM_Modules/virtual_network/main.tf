module "naming" {
  source        = "../naming"
  resource_type = "vnet"
  name          = var.name
  region        = var.region
}

resource "azapi_resource" "vnet" {
  type      = "Microsoft.Network/virtualNetworks@2024-05-01"
  name      = module.naming.standard_name
  location  = var.region
  tags      = var.tags
  parent_id = var.resource_group_id

  body = {
    properties = {
      addressSpace = {
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
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "time_sleep" "wait_for_vnet" {
  depends_on = [azapi_resource.vnet]

  create_duration = "10s"
}

module "subnets" {
  source = "../subnet"
  for_each  = tomap({ for k,v in var.subnets : v.name => v })

  name = each.value.name
  region = var.region
  virtual_network_id = azapi_resource.vnet.id
  resource_group_name = var.resource_group_name
  subnet_mask = each.value.subnet_mask
  ipam_pool_id = var.ipam_pool_id
  is_firewall_subnet = each.value.is_firewall_subnet
  is_bastion_subnet = each.value.is_bastion_subnet
  vnet_name = var.name

  depends_on = [time_sleep.wait_for_vnet]
}
