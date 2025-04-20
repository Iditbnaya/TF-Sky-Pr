# Firewall Module

This module creates an Azure Firewall with a public IP address and attaches it to a subnet.

## Features

- Creates an Azure Firewall
- Provisions a public IP address for the firewall
- Attaches the firewall to a subnet (AzureFirewallSubnet)
- Uses consistent naming conventions
- Outputs firewall IP addresses for routing configuration

## Usage

```hcl
module "firewall" {
  source = "./modules/firewall"

  name = "hub-fw"
  region = "israelcentral"
  resource_group_name = "hub-rg"
  subnet_id = "/subscriptions/subscription_id/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/AzureFirewallSubnet"
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | The name of the firewall | string | yes |
| region | The Azure region where resources will be created | string | yes |
| resource_group_name | The name of the resource group | string | yes |
| subnet_id | The ID of the subnet (must be named AzureFirewallSubnet) | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| firewall_id | The ID of the created firewall |
| firewall_public_ip | The public IP address of the firewall |
| fw_private_ip | The private IP address of the firewall |

## Dependencies

This module depends on:
- An existing resource group
- An existing subnet named AzureFirewallSubnet
- The naming module for consistent resource naming

## Notes

- The subnet must be named exactly "AzureFirewallSubnet"
- The subnet should have a minimum size of /26
- The firewall requires both inbound and outbound internet connectivity
- The module uses the AzureRM provider for the firewall and public IP resources 