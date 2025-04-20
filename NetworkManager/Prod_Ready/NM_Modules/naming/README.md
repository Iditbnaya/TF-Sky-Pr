# Naming Module

This module provides standardized naming for Azure resources following the naming convention: `<resource-type-prefix>-<sanitized-name>-<region-abbreviation>[-random-suffix]`.

## Features

- Consistent naming across all resources
- Resource-specific prefixes (e.g., "vnet" for virtual networks)
- Automatic character sanitization
- Handling of special case resources (e.g., storage accounts)
- Resource-specific character limit enforcement
- Optional random suffix for global uniqueness

## Usage

```hcl
module "resource_name" {
  source = "./modules/naming"
  
  resource_type = "resource_group"  # Type of resource
  name          = "example-name!"   # Will be sanitized automatically
  region        = "israelcentral"   # Azure region
  use_random_suffix = false         # Whether to add a random suffix (optional)
}

# The output will be "rg-examplename-il"
```

## Examples

| Resource Type | Input Name | Region | Output |
|---------------|------------|--------|--------|
| resource_group | example-name! | East US | rg-examplename-eus |
| virtual_network | hub network | West Europe | vnet-hubnetwork-weu |
| storage_account | backup-storage% | South Central US | stbackupstoragesscus |
| subnet | web_tier | North Europe | snet-webtier-neu |

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_type | The type of Azure resource | string | - | yes |
| name | The user-provided name (will be sanitized) | string | - | yes |
| region | The Azure region | string | - | yes |
| max_length | The maximum length for resource names | number | 63 | no |
| use_random_suffix | Whether to use a random suffix | bool | false | no |
| random_suffix_length | The length of the random suffix | number | 4 | no |
| subnet_name | Specific name for subnet resources | string | "" | no |

## Supported Resource Types

The module supports many Azure resource types, including:

- resource_group (prefix: rg)
- virtual_network (prefix: vnet)
- subnet (prefix: snet)
- storage_account (prefix: st)
- key_vault (prefix: kv)
- app_service (prefix: app)
- function_app (prefix: func)
- service_plan (prefix: plan)
- sql_server (prefix: sql)
- sql_database (prefix: sqldb)
- cosmos_account (prefix: cosmos)
- aks_cluster (prefix: aks)
- application_gateway (prefix: agw)
- network_security_group (prefix: nsg)
- route_table (prefix: rt)
- public_ip (prefix: pip)
- container_registry (prefix: acr)
- load_balancer (prefix: lb)
- log_analytics (prefix: log)
- bastion_host (prefix: bas)
- nat_gateway (prefix: nat)
- firewall (prefix: fw)

And many more as defined in the module's code.

## Outputs

| Name | Description |
|------|-------------|
| standard_name | The standardized resource name with hyphens |
| storage_account_name | Special format for storage accounts (no hyphens, 24 char max) |
| no_hyphen_name | Name format for resources that can't have hyphens (like ACR) |
| limited_length_name | Name with enforced character limits for specific resources |
| subnet_name | Specialized name format for subnets |

## Notes

- The module automatically transforms region names to their standard abbreviations (e.g., "East US" to "eus")
- Special handling is applied for storage accounts:
  - No hyphens allowed (removed)
  - Maximum length of 24 characters
  - All lowercase

- Special handling is applied for other resources with restrictions:
  - key_vault: Maximum length of 24 characters
  - container_registry: No hyphens allowed
  
- All names are converted to lowercase
- Invalid characters are removed based on resource-specific requirements 