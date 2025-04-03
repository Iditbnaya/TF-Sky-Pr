# Multi-Region Spokes Module

This module creates Azure spoke virtual networks across multiple regions and adds them to Network Manager network groups.

## Features

- Creates multiple spoke virtual networks in different regions
- Creates multiple subnets in each virtual network
- Creates network groups in Azure Network Manager for each region's spokes
- Integrates with IPAM for address space management
- Uses consistent naming conventions

## Usage

```hcl
module "multi_region_spokes" {
  source = "./modules/multi_region_spokes"

  network_manager_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm"
  ipam_pool_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm/ipamPools/spoke-ipam"
  region = "israelcentral"
  tags = {
    Environment = "Production"
  }
  
  spoke = {
    resource_group_name = "spokes"
    vnets = [
      {
        name = "spoke1"
        subnet_mask = 16
        subnets = [
          {
            name = "subnet1"
            subnet_mask = 24
          },
          {
            name = "subnet2"
            subnet_mask = 24
          }
        ]
      }
    ]
  }
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| network_manager_id | The ID of the Network Manager | string | yes |
| ipam_pool_id | The ID of the spoke IPAM pool | string | yes |
| region | The Azure region where resources will be created | string | yes |
| tags | A map of tags to apply to resources | map(string) | no |
| spoke | Object containing spoke network configurations | object | yes |

### Spoke Configuration Object

```hcl
spoke = {
  resource_group_name = "spokes"           # Resource group for spoke resources
  vnets = [                                # List of virtual networks
    {
      name = "spoke1"                      # Name of the virtual network
      subnet_mask = 16                     # CIDR mask for the VNet
      subnets = [                          # List of subnets
        {
          name = "subnet1"                 # Name of the subnet
          subnet_mask = 24                 # CIDR mask for the subnet
        }
      ]
    }
  ]
}
```

## Outputs

| Name | Description |
|------|-------------|
| region | The region of the deployment |
| spokes | Map of created spoke networks by name |
| network_group_id | The ID of the network group created for the spokes |

## Dependencies

This module depends on:
- An existing Network Manager
- An existing IPAM pool for spoke address allocation
- The resource_group module for creating the spoke resource group
- The virtual_network module for creating spoke networks
- The naming module for consistent resource naming

## Notes

- All spoke networks in a region are created in the same resource group
- A single network group is created per region containing all spoke networks
- The network group can be used with connectivity and routing configurations
- The module uses the AzAPI provider for resource creation 