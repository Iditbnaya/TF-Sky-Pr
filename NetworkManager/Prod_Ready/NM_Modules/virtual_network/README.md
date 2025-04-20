# Virtual Network Module

This module creates an Azure Virtual Network with subnets using the AzAPI provider. It supports IPAM integration for address space management.

## Features

- Creates a virtual network with IPAM integration
- Supports multiple subnet creation
- Optional firewall and bastion host deployment
- Consistent naming conventions
- Outputs subnet and network IDs for use in other modules

## Usage

```hcl
module "hub" {
  source = "./modules/virtual_network"

  name = "hub"
  region = "israelcentral"
  tags = {
    Environment = "Production"
  }

  resource_group_name = "hub-rg"
  resource_group_id = "/subscriptions/subscription_id/resourceGroups/hub-rg"
  ipam_pool_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm/ipamPools/example-pool"
  subnet_mask = 16

  subnets = [
    {
      name = "fw"
      subnet_mask = 24
      is_firewall_subnet = true
    },
    {
      name = "bastion"
      subnet_mask = 24
      is_bastion_subnet = true
    }
  ]
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | The name of the virtual network | string | yes |
| region | The Azure region where resources will be created | string | yes |
| tags | A map of tags to apply to all resources | map(string) | no |
| resource_group_name | The name of the resource group | string | yes |
| resource_group_id | The ID of the resource group | string | yes |
| ipam_pool_id | The ID of the IPAM pool to use for address allocation | string | yes |
| subnet_mask | The subnet mask for the virtual network | number | yes |
| subnets | List of subnet configurations | list(object) | yes |

### Subnet Configuration Object

```hcl
subnets = [
  {
    name = "example-subnet"       # Name of the subnet
    subnet_mask = 24              # Subnet mask (CIDR notation)
    is_firewall_subnet = false    # Optional: Set to true for Azure Firewall subnet
    is_bastion_subnet = false     # Optional: Set to true for Azure Bastion subnet
  }
]
```

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | The ID of the created virtual network |
| vnet_name | The name of the created virtual network |
| fw_private_ip | The private IP address of the firewall as a string |

## Dependencies

This module depends on:
- The naming module for consistent resource naming
- The subnet module for subnet creation
- An existing IPAM pool for address allocation

## Notes

- Setting `is_firewall_subnet = true` will create a subnet named "AzureFirewallSubnet" and deploy an Azure Firewall
- Setting `is_bastion_subnet = true` will create a subnet named "AzureBastionSubnet" and deploy an Azure Bastion Host
- The module uses the AzAPI provider for resource creation 