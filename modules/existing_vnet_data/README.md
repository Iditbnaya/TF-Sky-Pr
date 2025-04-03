# Existing VNet Data Module

This module retrieves information about existing virtual networks and their associated resources (firewalls, etc.) for use in multi-region deployments.

## Features

- Retrieves existing virtual network information
- Retrieves existing firewall information
- Supports multiple regions
- Provides data outputs for use in other modules

## Usage

```hcl
module "existing_vnet_data" {
  source = "./modules/existing_vnet_data"

  resource_group_name = "hub-rg"
  vnet_name = "hub-vnet"
  fw_name = "hub-fw"
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| resource_group_name | The name of the resource group containing the existing resources | string | yes |
| vnet_name | The name of the existing virtual network | string | yes |
| fw_name | The name of the existing firewall | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | The ID of the existing virtual network |
| vnet_name | The name of the existing virtual network |
| vnet_address_space | The address space of the existing virtual network |
| fw_id | The ID of the existing firewall |
| fw_name | The name of the existing firewall |
| fw_private_ip | The private IP address of the existing firewall |

## Dependencies

This module depends on:
- An existing virtual network
- An existing firewall in the virtual network
- Appropriate permissions to read the resources

## Notes

- This module is used to gather information about existing resources for use in multi-region deployments
- The module uses data sources to read existing resources
- All resources must exist before this module can be used
- The module uses the Azure provider for data source queries 