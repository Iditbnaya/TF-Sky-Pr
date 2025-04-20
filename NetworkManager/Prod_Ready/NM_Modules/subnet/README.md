# Subnet Module

This module creates an Azure subnet with support for optional Azure Firewall or Azure Bastion deployment.

## Features

- Creates a subnet with IPAM integration
- Optional Azure Firewall deployment
- Optional Azure Bastion deployment
- Consistent naming convention

## Usage

```hcl
module "subnet" {
  source = "../subnet"
  
  name = "frontend"
  region = "israelcentral"
  virtual_network_id = "/subscriptions/subscription_id/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet"
  resource_group_name = "example-rg"
  subnet_mask = 24
  ipam_pool_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm/ipamPools/example-pool"
  is_firewall_subnet = false
  is_bastion_subnet = false
  vnet_name = "hub"
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | The name of the subnet | string | yes |
| region | The Azure region where resources will be created | string | yes |
| virtual_network_id | The ID of the virtual network | string | yes |
| resource_group_name | The name of the resource group | string | yes |
| subnet_mask | The subnet mask (CIDR notation) | number | yes |
| ipam_pool_id | The ID of the IPAM pool to use for address allocation | string | yes |
| is_firewall_subnet | Whether this subnet is for Azure Firewall | bool | no |
| is_bastion_subnet | Whether this subnet is for Azure Bastion | bool | no |
| vnet_name | The name of the virtual network | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| subnet_name | The name of the created subnet |
| fw_private_ip | The private IP address of the firewall (if deployed) |

## Dependencies

This module depends on:
- The naming module for consistent resource naming
- The firewall module (optional)
- The bastion module (optional)

## Notes

- If `is_firewall_subnet` is set to `true`, the subnet will be named "AzureFirewallSubnet" and an Azure Firewall will be deployed
- If `is_bastion_subnet` is set to `true`, the subnet will be named "AzureBastionSubnet" and an Azure Bastion Host will be deployed
- The module uses the AzAPI provider for resource creation 