# Resource Group Module

This module creates an Azure Resource Group using the AzAPI provider with standardized naming.

## Features

- Creates an Azure Resource Group
- Uses consistent naming convention
- Applies tags for resource management
- Outputs resource group ID for use in other modules

## Usage

```hcl
module "resource_group" {
  source = "./modules/resource_group"

  name = "example"
  region = "israelcentral"
  tags = {
    Environment = "Production"
    Owner = "DevOps"
  }
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | The name of the resource group | string | yes |
| region | The Azure region where resources will be created | string | yes |
| tags | A map of tags to apply to the resource | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the created resource group |
| name | The name of the created resource group |
| standard_name | The standardized name of the resource group (with prefix and region) |

## Dependencies

This module depends on:
- The naming module for consistent resource naming

## Notes

- The resource group name will follow the pattern: `rg-<name>-<region>`
- The module uses the AzAPI provider for resource creation
- Resource group names must be unique within a subscription
- Maximum length for resource group names is 90 characters 