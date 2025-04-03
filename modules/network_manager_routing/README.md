# Network Manager Routing Module

This module creates routing configurations in Azure Network Manager to define routing policies for network groups.

## Features

- Creates a routing configuration in Azure Network Manager
- Defines routing rules for network groups
- Routes traffic through a specified firewall
- Uses consistent naming conventions

## Usage

```hcl
module "user_defined_routes" {
  source = "./modules/network_manager_routing"

  name = "udr"
  region = "israelcentral"
  network_manager_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm"
  network_group_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm/networkGroups/example-ng"
  fw_private_ip = "10.1.0.4"
  resource_group_name = "example-rg"
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | The name of the routing configuration | string | yes |
| region | The Azure region where resources will be created | string | yes |
| network_manager_id | The ID of the Network Manager | string | yes |
| network_group_id | The ID of the network group to apply routing to | string | yes |
| fw_private_ip | The private IP address of the firewall | string | yes |
| resource_group_name | The name of the resource group | string | yes |

## Resources Created

- Network Manager Routing Configuration
- Network Manager Routing Rule Collection
- Network Manager Routing Rule (default route to firewall)

## Dependencies

This module depends on:
- An existing Network Manager
- An existing Network Group
- An existing Azure Firewall with a known private IP address
- The naming module for consistent resource naming

## Notes

- This module creates a default route (0.0.0.0/0) pointing to the specified firewall
- After applying this configuration, you must manually deploy it in the Azure Portal
- The module uses the AzAPI provider for resource creation

## Post-Deployment Steps

After deploying this module, you need to manually apply the routing configuration in the Azure Portal:

1. Navigate to the Network Manager in the Azure Portal
2. Go to "Configurations" → "Routing configurations"
3. Select the routing configuration created by this module
4. Click "Deploy to network"
5. Select the appropriate network group and click "Deploy" 