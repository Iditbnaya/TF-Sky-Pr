# Bastion Module

This module creates an Azure Bastion Host with a public IP address and attaches it to a subnet.

## Features

- Creates an Azure Bastion Host
- Provisions a public IP address for the bastion
- Attaches the bastion to a subnet (AzureBastionSubnet)
- Uses consistent naming conventions

## Usage

```hcl
module "bastion" {
  source = "./modules/bastion"

  name = "hub-bastion"
  region = "israelcentral"
  resource_group_name = "hub-rg"
  subnet_id = "/subscriptions/subscription_id/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/AzureBastionSubnet"
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | The name of the bastion host | string | yes |
| region | The Azure region where resources will be created | string | yes |
| resource_group_name | The name of the resource group | string | yes |
| subnet_id | The ID of the subnet (must be named AzureBastionSubnet) | string | yes |

## Outputs

None.

## Dependencies

This module depends on:
- An existing resource group
- An existing subnet named AzureBastionSubnet
- The naming module for consistent resource naming

## Notes

- The subnet must be named exactly "AzureBastionSubnet"
- The subnet should have a minimum size of /27
- The bastion requires outbound internet connectivity
- The module uses the AzureRM provider for the bastion and public IP resources
- Azure Bastion provides secure and seamless RDP and SSH access to virtual machines via the Azure Portal 