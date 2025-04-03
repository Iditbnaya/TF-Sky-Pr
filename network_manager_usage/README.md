# Network Manager Usage

This module is specifically designed to work with an existing Network Manager deployment. It has a **direct dependency** on the `network_manager_deployment_existing_hub` module and cannot function independently.

## Dependency Relationship

```
Network Manager Deployment (Existing Hub)
            ↓
      [Terraform State]
            ↓
    Network Manager Usage
```

This module relies on the following resources that must be created by the network_manager_deployment_existing_hub first:

- Network Manager instance with configured scope accesses
- IPAM pools with defined address spaces for each region
- Existing hub virtual networks with firewalls
- Initial spoke networks (if configured)

## Features

- Uses the Terraform state outputs from the network_manager_deployment_existing_hub
- Creates additional spoke networks in regions already configured by network_manager_deployment_existing_hub
- Connects new spokes to existing hub networks created or registered by network_manager_deployment_existing_hub
- Configures routing through the existing hub firewalls
- Leverages existing IPAM pools for address space allocation

## Resource Naming Convention

All resources deployed by this module use the naming convention managed by the naming module. Resource names follow this pattern:

`<resource-type-prefix>-<sanitized-name>-<region-abbreviation>[-random-suffix]`

Where:
- **resource-type-prefix**: Automatically determined based on the Azure resource type (e.g., "vnet", "snet", "rt")
- **sanitized-name**: The free text name YOU provide, cleaned of invalid characters
- **region-abbreviation**: Automatically converted from the full region name to its short abbreviation (e.g., "West Europe" becomes "weu")
- **random-suffix** (optional): A random string for ensuring global uniqueness when enabled

**Important**: When providing resource names in your configuration, you only need to specify the free text name component (the "sanitized-name" part). The module will automatically add the appropriate prefix, region abbreviation, and handle any sanitization required.

## Prerequisites

Before using this module, you must:

1. Complete the network_manager_deployment_existing_hub deployment
2. Have access to the Terraform state from the network_manager_deployment_existing_hub
3. Configure the terraform_remote_state data source to access that state

## Deployment Steps

1. **Initialize Terraform**
   ```bash
   terraform init -backend-config=../backend.conf
   ```

2. **Configure Variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

   A `terraform.tfvars.example` file is provided as a template with placeholder values. Copy this file to `terraform.tfvars` and replace the placeholders with your actual values before deployment. The example file includes the necessary variable structure for spoke networks and firewall rule collections.

3. **Deploy the Resources**
   ```bash
   terraform apply
   ```

4. **Post-Deployment Steps**

   **Deploy the routing configuration in the Network Manager:**
   - After spoke networks are created, you must manually deploy the routing configuration
   - Log in to the Azure Portal
   - Navigate to the Network Manager resource
   - Go to "Configurations" → "Routing configurations"
   - Select the created routing configuration 
   - Click on "Deploy to network"
   - Select the appropriate network group and click "Deploy"

   > **Important Note**: Currently, the routing configuration is not automatically deployed through Terraform. This manual step is necessary to ensure that your new spoke networks have proper routing to the hub firewall.

## State Access Configuration

This module offers two methods to access the state from the network_manager_deployment_existing_hub:

### Using Local State (Default)

```hcl
# Access the outputs from a local state file
data "terraform_remote_state" "local_existing_hub_deployment" {
  backend = "local"
  config = {
    path = "../network_manager_deployment_existing_hub/terraform.tfstate"
  }
}
```

### Using Remote State (Azure Storage)

```hcl
# Uncomment and configure to use remote state stored in Azure
data "terraform_remote_state" "network_manager_deployment_existing_hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = "network-manager-rg"
    storage_account_name = "networkmanagerstorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

## Critical State Dependencies

This module depends on the following outputs from the network_manager_deployment_existing_hub state:

1. `network_manager_id` - The ID of the Network Manager
2. `ipam_pools` - The IPAM pool IDs for each region
3. `hub_vnet_ids` - The IDs of the hub virtual networks
4. `fw_private_ip` - The private IP addresses of the hub firewalls

If any of these outputs are missing from the network_manager_deployment_existing_hub state, this module will fail to deploy.

## Variable Structure

### Required Variables

```hcl
# Tags to apply to all resources (optional)
tags = {
  Environment = "Dev"
  Project     = "NetworkManager"
  Owner       = "DevOps"
}
```

### Spoke Network Configuration

```hcl
# Spoke configurations by region
spoke = [
  {
    region = "westeurope"  # MUST match a region from network_manager_deployment_existing_hub
    spokes = [
      {
        resource_group_name = "rg-spokes-westeu"
        vnets = [
          {
            name = "spoke1"
            subnet_mask = 16
            subnets = [
              {
                name = "subnet1"
                subnet_mask = 24
              },
              {
                name = "subnet2"
                subnet_mask = 24
              }
            ]
          },
          {
            name = "spoke2"
            subnet_mask = 16
            subnets = [
              {
                name = "subnet1"
                subnet_mask = 24
              },
              {
                name = "subnet2"
                subnet_mask = 24
              }
            ]
          }
        ]
      }
    ]
  },
  {
    region = "northeurope"  # MUST match a region from network_manager_deployment_existing_hub
    spokes = [
      {
        resource_group_name = "rg-spokes-northeu"
        vnets = [
          {
            name = "spoke1"
            subnet_mask = 16
            subnets = [
              {
                name = "subnet1"
                subnet_mask = 24
              }
            ]
          }
        ]
      }
    ]
  }
]
```

### Firewall Rule Collections

```hcl
# Firewall Network Rule Collections (Optional)
fw_network_rule_collections = [
  {
    name     = "AllowICMPInternal"
    priority = 1000
    action   = "Allow"
    rules = [
      {
        name                  = "AllowICMPInternal"
        source_addresses      = ["10.0.0.0/8"]
        destination_addresses = ["10.0.0.0/8"]
        destination_ports     = ["*"]
        protocols             = ["ICMP"]
      }
    ]
  }
]
```

## Resource Creation

This module creates the following resources:

1. **Spoke Networks**: Virtual networks in the specified regions
2. **Spoke Subnets**: Subnets within each spoke network
3. **Network Groups**: Adds the new spoke networks to Network Manager network groups
4. **Routing**: Configures route tables to direct traffic through the hub firewall
5. **Firewall Rules**: Optionally adds network rule collections to the existing hub firewalls

## Multi-Region Support

The module fully supports multiple regions:

- Each region MUST already be configured in the network_manager_deployment_existing_hub
- Spoke networks are created in the specified regions
- Routing is configured through the hub firewall in each region
- IPAM pools from each region are used for address space allocation
- Firewall rules can be region-specific by using appropriate address spaces

## Region Matching Requirements

A critical requirement of this module is that the regions specified in the spoke configuration must exactly match regions that were configured in the network_manager_deployment_existing_hub. This is because:

1. The IPAM pools are region-specific
2. The hub firewalls are region-specific
3. The routing configurations are region-specific

If you specify a region that wasn't included in the network_manager_deployment_existing_hub, the module will fail to deploy because it won't be able to find the corresponding resources in the Terraform state.

## Notes

- The spoke network configuration must specify regions that match those in the network_manager_deployment_existing_hub
- Each region must have a hub network and firewall already configured by network_manager_deployment_existing_hub
- The IPAM pools for each region must have sufficient address space for the new spoke networks
- All outputs from the network_manager_deployment_existing_hub are accessible via the terraform_remote_state data source 