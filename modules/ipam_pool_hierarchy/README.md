# IPAM Pool Hierarchy Module

This module creates a hierarchical structure of IP Address Management (IPAM) pools in Azure Network Manager, including a parent pool with child pools for hub and spoke networks.

## Features

- Creates a complete IPAM hierarchy in a single module call
- Establishes parent-child relationships automatically
- Supports separate address spaces for hub and spoke networks
- Handles dependency management between pools
- Uses consistent naming conventions

## Architecture

The module creates the following hierarchy:
```
Parent IPAM Pool (e.g., 10.0.0.0/8)
│
├── Hub IPAM Pool (e.g., 10.1.0.0/16, 10.20.0.0/16)
│
└── Spoke IPAM Pool (e.g., 10.128.0.0/9)
```

## Usage

```hcl
module "ipam_pool_hierarchy" {
  source = "./modules/ipam_pool_hierarchy"

  name = "parent-ipam"
  region = "israelcentral"
  tags = {
    Environment = "Production"
  }
  
  network_manager_id = module.network_manager.id
  address_prefixes = ["10.0.0.0/8"]
  
  hub_pool = {
    name = "hub"
    address_prefixes = ["10.1.0.0/16", "10.20.0.0/16"]
  }
  
  spoke_pools = {
    name = "spokes"
    address_prefixes = ["10.128.0.0/9"]
  }
}
```

## Integration with Existing Hub VNet

When using this module with an existing hub VNet:

1. The hub_pool address_prefixes must match the exact address space of your existing hub VNet
2. After deployment, manually assign the existing hub VNet to the created hub IPAM pool through the Azure Portal

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| name | Name of the parent IPAM pool | string | yes |
| region | Azure region where resources will be created | string | yes |
| tags | Map of tags to apply to all resources | map(string) | no |
| network_manager_id | ID of the Network Manager | string | yes |
| address_prefixes | List of address prefixes for the parent pool in CIDR notation | list(string) | yes |
| hub_pool | Configuration object for hub IPAM pool | object | yes |
| spoke_pools | Configuration object for spoke IPAM pool | object | yes |

### Hub Pool Configuration Object

```hcl
hub_pool = {
  name = string             # Name of the hub IPAM pool
  address_prefixes = list   # List of CIDR address prefixes
}
```

### Spoke Pools Configuration Object

```hcl
spoke_pools = {
  name = string             # Name of the spoke IPAM pool
  address_prefixes = list   # List of CIDR address prefixes
}
```

## Outputs

| Name | Description |
|------|-------------|
| parent_pool_id | ID of the parent IPAM pool |
| hub_pool_id | ID of the hub IPAM pool |
| spoke_pool_ids | ID of the spoke IPAM pool |
| hub_pool_creation_time | Creation time of the hub IPAM pool (for dependency management) |
| spoke_pool_creation_times | Creation time of the spoke IPAM pool (for dependency management) |

## Dependencies

This module depends on:
- An existing Network Manager
- The ipam_pool module for individual pool creation
- The naming module for consistent resource naming

## Best Practices

1. The parent pool should have an address space that encompasses all child pools
2. Child pools should not have overlapping address spaces
3. Deploy this module before creating any virtual networks
4. When integrating with existing infrastructure, ensure address spaces match exactly
5. Address prefixes must be in valid CIDR notation

## Notes

- The module includes a sleep period after resource creation to ensure Azure has time to replicate the resources
- If you're using this with an existing hub deployment, make sure to assign the hub VNet to the hub IPAM pool after deployment
- For multi-region deployments, create separate instances of this module for each region 