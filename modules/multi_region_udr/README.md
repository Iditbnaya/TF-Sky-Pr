# Multi-Region UDR Module

This module creates User Defined Routes (UDRs) for spoke networks across multiple regions, configuring routing through the hub firewall.

## Features

- Creates UDRs for spoke networks in different regions
- Configures routes through the hub firewall
- Integrates with Network Manager for route management
- Supports multiple spoke networks per region
- Uses consistent naming conventions

## Usage

```hcl
module "multi_region_udr" {
  source = "./modules/multi_region_udr"

  network_manager_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm"
  ipam_pool_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm/ipamPools/spoke-ipam"
  fw_private_ip = "10.1.0.4"
  nm_resource_group_name = "network-manager-rg"
  existing_hub_vnet_id = "/subscriptions/subscription_id/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet"
  connectivity_config = {
    name = "HubAndSpoke"
  }
  
  spokes = {
    spoke1 = {
      vnet_id = "/subscriptions/subscription_id/resourceGroups/spokes/providers/Microsoft.Network/virtualNetworks/spoke1"
      address_prefixes = ["10.128.0.0/16"]
    }
  }
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| network_manager_id | The ID of the Network Manager | string | yes |
| ipam_pool_id | The ID of the spoke IPAM pool | string | yes |
| fw_private_ip | The private IP address of the hub firewall | string | yes |
| nm_resource_group_name | The name of the Network Manager resource group | string | yes |
| existing_hub_vnet_id | The ID of the existing hub virtual network | string | yes |
| connectivity_config | The connectivity configuration object | object | yes |
| spokes | Map of spoke network configurations | map(object) | yes |

### Connectivity Configuration Object

```hcl
connectivity_config = {
  name = "HubAndSpoke"  # Name of the connectivity configuration
}
```

### Spoke Configuration Object

```hcl
spokes = {
  spoke1 = {
    vnet_id = "/subscriptions/subscription_id/resourceGroups/spokes/providers/Microsoft.Network/virtualNetworks/spoke1"
    address_prefixes = ["10.128.0.0/16"]
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| routing_config_id | The ID of the created routing configuration |
| routing_config_name | The name of the created routing configuration |

## Dependencies

This module depends on:
- An existing Network Manager
- An existing hub virtual network with firewall
- The multi_region_spokes module for spoke network information
- The naming module for consistent resource naming

## Notes

- Creates a routing configuration in Network Manager for each region
- Configures routes through the hub firewall for all spoke networks
- Supports multiple spoke networks per region
- The module uses the AzAPI provider for resource creation 