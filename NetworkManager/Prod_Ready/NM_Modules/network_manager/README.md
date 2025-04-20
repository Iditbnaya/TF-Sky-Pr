# Network Manager Module

This module creates an Azure Network Manager to centrally manage and govern networking resources across subscriptions and management groups.

## Features

- Creates an Azure Network Manager resource
- Configures scope accesses (Connectivity, SecurityAdmin, Routing)
- Defines management scope for subscriptions and management groups
- Uses consistent naming conventions

## Usage

```hcl
module "network_manager" {
  source = "./modules/network_manager"

  name = "nm"
  region = "israelcentral"
  tags = {
    Environment = "Production"
  }
  
  resource_group_name = "network-manager-rg"
  
  scope_accesses = ["Connectivity", "SecurityAdmin", "Routing"]
  management_groups = ["00000000-0000-0000-0000-000000000000"]  # Management group GUIDs only
  subscriptions = ["00000000-0000-0000-0000-000000000000"]      # Subscription GUIDs only
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | The name of the Network Manager | string | yes |
| region | The Azure region where resources will be created | string | yes |
| tags | A map of tags to apply to the resource | map(string) | no |
| resource_group_name | The name of the resource group | string | yes |
| scope_accesses | List of scope access types (Connectivity, SecurityAdmin, SecurityUser, Routing) | list(string) | yes |
| management_groups | List of management group GUIDs (without the full resource path) | list(string) | no |
| subscriptions | List of subscription GUIDs (without the full resource path) | list(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the created Network Manager |
| name | The name of the created Network Manager |
| creation_time | The creation time of the Network Manager (used for dependencies) |

## Dependencies

This module depends on:
- An existing resource group
- The naming module for consistent resource naming

## Notes

- At least one of `management_groups` or `subscriptions` should be provided
- Management group IDs should be provided as GUIDs only (e.g., "00000000-0000-0000-0000-000000000000")
- Subscription IDs should be provided as GUIDs only (e.g., "00000000-0000-0000-0000-000000000000")
- The module will automatically format the provided GUIDs into the correct resource ID format
- Scope accesses determine what features are available in the Network Manager:
  - Connectivity: Enables creating connectivity configurations (hub and spoke, mesh)
  - SecurityAdmin: Enables creating and editing security admin configurations
  - SecurityUser: Enables applying security admin configurations
  - Routing: Enables creating routing configurations
- The module uses the AzAPI provider for resource creation 