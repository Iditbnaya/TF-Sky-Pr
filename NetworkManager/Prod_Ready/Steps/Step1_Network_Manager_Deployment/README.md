# Step 1: Network Manager Deployment

## Overview
This step deploys the Azure Network Manager and all related resources that form the foundation of the network architecture. Network Manager is a central hub for managing network configurations across multiple virtual networks in Azure.

## Resources Deployed
- **Resource Group**: For Network Manager resources
- **Azure Network Manager**: Central network management service
- **IPAM Pools Hierarchy**:
  - Parent IPAM Pool (10.0.0.0/8)
  - Regional IPAM Pools (One for each defined region)
  - Hub, Spokes, and optional Monitoring pools per region
- **Network Groups**: Regional groupings of network resources
- **Connectivity Configurations**: Hub and Spoke topology definitions
- **Routing Configurations**: User-defined routes for traffic management through firewalls

## Naming Conventions
The deployment follows these naming conventions:
- **Network Manager**: Based on the name provided in variables (default: "nm")
- **Resource Group**: Matches the Network Manager name
- **IPAM Pools**: 
  - Parent Pool: "parent-pool" 
  - Regional Pools: Named after the region
  - Functional Pools: "hub-pool", "spokes-pool", "monitoring-pool"
- **Network Groups**: "regional-ng" with region suffix

## How It Works
1. **Resource Group Creation**: First, a resource group is created to contain the Network Manager resources.
2. **Network Manager Deployment**: The Network Manager is deployed with the specified scope access permissions.
3. **IPAM Pool Hierarchy Creation**:
   - Parent IPAM Pool is created with a /8 subnet (10.0.0.0/8 by default)
   - Regional IPAM Pools are created under the parent pool
   - Within each region, specialized pools (hub, spokes, monitoring) are created
4. **Network Group Creation**: Network groups are created for each region to organize network resources
5. **Connectivity and Routing Configuration**: 
   - Connectivity configurations establish hub and spoke topologies
   - UDRs (User Defined Routes) configure traffic to route through firewalls

## IPAM Pool Configuration
The IPAM pool hierarchy offers two approaches for address allocation:

1. **Dynamic Address Allocation (Recommended)**:
   - Specify only the `subnet_mask` value
   - Addresses will be automatically calculated from the parent pool
   - Hub subnet masks should be between 24-30
   - Spoke subnet masks should be between 12-29
   - Monitoring subnet masks should be between 16-29

2. **Static Address Allocation**:
   - Specify the exact `address_prefix` to use
   - When using static addresses, `is_child_pool` must be set to `false`
   - Static allocation is not recommended unless there's a specific need

You must specify either `subnet_mask` or `address_prefix` for each pool. If both are provided, `address_prefix` takes precedence.

## Integration with Existing Infrastructure
- The deployment can incorporate existing hub networks by providing their VNet IDs and firewall private IPs
- Proper routing and connectivity configurations are established automatically

## Prerequisites
- Azure subscription with owner/contributor permissions
- Existing hub VNets (if using the existing_hubs_info variable)
- **For Management Group Scope**: If you plan to use Management Groups as the scope for Network Manager, you must first register the Microsoft.Network provider at the management group level by running:
  ```
  az provider register --namespace Microsoft.Network --management-group <management-group-id>
  ```
  This step is required before Network Manager can be scoped to a Management Group

## Outputs
- Network Manager ID
- Network Group IDs (per region)
- Spoke IPAM Pool IDs (per region)

These outputs are utilized by subsequent deployment steps to ensure proper integration of new resources into the managed network.

## Getting Started
1. Copy `backend.tf.example` to `backend.tf` and fill in your storage account details
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and customize variables
3. If using Management Groups, register the Microsoft.Network provider at the management group level
4. Run `terraform init` to initialize the deployment
5. Run `terraform plan` to preview changes
6. Run `terraform apply` to deploy the resources 