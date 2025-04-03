# Spokes Module

This module creates Azure spoke virtual networks with subnets and adds them to a Network Manager network group.

## Features

- Creates multiple spoke virtual networks in a resource group
- Creates multiple subnets in each virtual network
- Creates a network group in Azure Network Manager for the spokes
- Integrates with IPAM for address space management
- Uses consistent naming conventions

## Usage

```hcl
module "spokes" {
  source = "./modules/spokes"

  network_manager_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm"
  resource_group_name = "spokes"
  region = "israelcentral"
  tags = {
    Environment = "Production"
  }
  ipam_pool_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm/ipamPools/spoke-ipam"
  
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
    },
    {
      name = "spoke2"
      subnet_mask = 16
      subnets = [
        {
          name = "subnet1"
          subnet_mask = 24
        }
      ]
    }
  ]
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| network_manager_id | The ID of the Network Manager | string | yes |
| resource_group_name | The name of the resource group for spoke resources | string | yes |
| region | The Azure region where resources will be created | string | yes |
| tags | A map of tags to apply to resources | map(string) | no |
| ipam_pool_id | The ID of the spoke IPAM pool | string | yes |
| vnets | List of virtual network configurations | list(object) | yes |

### Virtual Network Configuration Object

```hcl
vnets = [
  {
    name = "spoke1"            # Name of the virtual network
    subnet_mask = 16           # CIDR mask for the VNet
    subnets = [                # List of subnets to create
      {
        name = "subnet1"       # Name of the subnet
        subnet_mask = 24       # CIDR mask for the subnet
      }
    ]
  }
]
```

## Outputs

| Name | Description |
|------|-------------|
| resource_group_name | The name of the resource group |
| network_group_id | The ID of the network group created for the spokes |

## Dependencies

This module depends on:
- An existing Network Manager
- An existing IPAM pool for spoke address allocation
- The resource_group module for creating the spoke resource group
- The virtual_network module for creating spoke networks
- The naming module for consistent resource naming

## Notes

- All spoke networks are created in the same resource group
- A single network group is created containing all spoke networks
- The network group can be used with connectivity and routing configurations
- The module uses the AzAPI provider for resource creation 