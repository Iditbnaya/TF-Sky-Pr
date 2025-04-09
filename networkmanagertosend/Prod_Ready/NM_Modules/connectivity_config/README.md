# Connectivity Configuration Module

This module creates a connectivity configuration in Azure Network Manager to establish hub and spoke network topology.

## Features

- Creates a hub and spoke connectivity configuration
- Links the hub virtual network to spoke network groups
- Uses consistent naming conventions

## Usage

```hcl
module "connectivity_config" {
  source = "./modules/connectivity_config"

  name = "HubAndSpoke"
  network_manager_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm"
  region = "israelcentral"
  hub_id = "/subscriptions/subscription_id/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet"
  network_group_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm/networkGroups/spoke-group"
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | The name of the connectivity configuration | string | yes |
| network_manager_id | The ID of the Network Manager | string | yes |
| region | The Azure region where resources will be created | string | yes |
| hub_id | The ID of the hub virtual network | string | yes |
| network_group_id | The ID of the network group containing spoke networks | string | yes |

## Resources Created

- Network Manager Connectivity Configuration (Hub and Spoke type)
- Network Manager Connectivity Group (linking hub to spoke network group)

## Dependencies

This module depends on:
- An existing Network Manager
- An existing hub virtual network
- An existing network group containing spoke networks
- The naming module for consistent resource naming

## Notes

- This module creates a hub and spoke topology in Azure Network Manager
- After applying this configuration, you must manually deploy it in the Azure Portal
- The hub virtual network will be connected to all spoke networks in the specified network group
- The module uses the AzAPI provider for resource creation

## Post-Deployment Steps

After deploying this module, you need to manually apply the connectivity configuration in the Azure Portal:

1. Navigate to the Network Manager in the Azure Portal
2. Go to "Configurations" → "Connectivity configurations"
3. Select the connectivity configuration created by this module
4. Click "Deploy to network"
5. Select the appropriate network group and click "Deploy" 