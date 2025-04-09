# IPAM Pool Module

This module creates an IP Address Management (IPAM) pool in Azure Network Manager to manage IP address allocations.

## Features

- Creates parent or child IPAM pools
- Supports multiple address prefixes
- Integrates with Azure Network Manager
- Uses consistent naming conventions

## Usage

### Parent Pool

```hcl
module "parent_ipam_pool" {
  source = "./modules/ipam_pool"

  name = "parent-ipam"
  region = "israelcentral"
  tags = {
    Environment = "Production"
  }
  
  address_prefixes = ["10.0.0.0/8"]
  network_manager_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm"
}
```

### Child Pool

```hcl
module "hub_ipam_pool" {
  source = "./modules/ipam_pool"

  name = "hub-ipam"
  region = "israelcentral"
  tags = {
    Environment = "Production"
  }
  
  address_prefixes = ["10.1.0.0/16", "10.20.0.0/16"]
  network_manager_id = "/subscriptions/subscription_id/providers/Microsoft.Network/networkManagers/example-nm"
  is_parent_pool = false
  parent_pool_name = "parent-ipam"
}
```

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | The name of the IPAM pool | string | yes |
| region | The Azure region where resources will be created | string | yes |
| tags | A map of tags to apply to the resource | map(string) | no |
| address_prefixes | List of address prefixes in CIDR notation | list(string) | yes |
| network_manager_id | The ID of the Network Manager | string | yes |
| is_parent_pool | Whether this is a parent (top-level) pool | bool | no |
| parent_pool_name | Name of the parent pool (required if is_parent_pool is false) | string | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the created IPAM pool |
| name | The name of the created IPAM pool |
| creation_time | The creation time of the IPAM pool (used for dependencies) |

## Dependencies

This module depends on:
- An existing Network Manager
- An existing parent IPAM pool (if creating a child pool)
- The naming module for consistent resource naming

## Notes

- Parent pools should be created before child pools
- Multiple child pools can be created under a single parent pool
- Address prefixes must be in valid CIDR notation
- Child pools' address prefixes should be contained within the parent pool's address space
- The module uses the AzAPI provider for resource creation 