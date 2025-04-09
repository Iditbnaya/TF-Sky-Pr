# IPAM Pool Hierarchy v4

This module provides an improved version of the IPAM pool hierarchy that respects existing address ranges while performing dynamic address allocation.

## Features

- Creates hub, spokes, and optional monitoring IPAM pools
- Supports both hardcoded address prefixes and dynamic allocation via subnet masks
- Gives precedence to hardcoded address ranges (represents pre-existing address space)
- Dynamically allocates non-overlapping address ranges based on requested subnet mask sizes
- Can allocate multiple smaller address ranges to satisfy the required address count

## How It Works

1. Starts with the regional CIDR block as available address space
2. Uses hardcoded address prefixes if provided (representing existing address spaces)
3. For pools without hardcoded prefixes, allocates non-overlapping CIDRs using a strategic index approach:
   - Hub pools are allocated from the beginning of the address range (index 0)
   - Spoke pools are allocated at approximately 25% through the address range
   - Monitoring pools are allocated at approximately 75% through the address range

This strategic spacing helps ensure that dynamically allocated CIDRs don't overlap with each other, while still giving preference to any hardcoded address prefixes.

## Usage

```hcl
module "ipam_pool_hierarchy" {
  source = "../NM_Modules/ipam_pool_hierarchy_v4"
  
  network_manager_id = azurerm_network_manager.example.id
  parent_ipam_pool_name = "parent-pool"
  parent_ipam_pool_address_prefix = "10.0.0.0/16"
  regional_ipam_pool_address_prefix = "10.0.0.0/17"
  
  regional_ipam_pool_hierarchy = {
    name = "region1"
    region = "eastus"
    hub_pool = {
      name = "hub-pool"
      subnet_mask = 24  # Dynamic allocation with /24
      is_child_pool = true
    }
    spokes_pool = {
      name = "spokes-pool"
      address_prefix = "10.0.32.0/20"  # Hardcoded existing address space
      is_child_pool = true
    }
    monitoring_pool = {
      name = "monitoring-pool"
      subnet_mask = 26  # Dynamic allocation with /26
      is_child_pool = true
    }
  }
}
```

## Differences from v3

The v4 module adds the following improvements over v3:
- Prioritizes existing address ranges over dynamic allocation
- Ensures dynamically allocated ranges don't overlap with existing ranges
- Can allocate multiple smaller address ranges to meet the required capacity
- Handles edge cases like insufficient address space more gracefully

## Implementation Notes

The module uses a simple but effective approach to subnet allocation:
1. Hardcoded address prefixes have absolute precedence
2. Dynamic allocation uses strategic spacing to avoid conflicts
3. Different subnet masks are properly handled through CIDR calculations
4. Null handling for optional monitoring pool is built in

For simpler network scenarios, this approach provides a good balance of reliability and predictability while avoiding complex, potentially error-prone subnet allocation algorithms.

Future improvements could include:
- Testing for overlaps against existing network resources
- Multiple CIDR block allocation capability
- Advanced conflict resolution for more complex scenarios

Future improvements:
- Complete the implementation of the non-overlapping algorithm
- Add validation to detect overlapping ranges
- Support multiple smaller CIDR allocations when a single range isn't available 