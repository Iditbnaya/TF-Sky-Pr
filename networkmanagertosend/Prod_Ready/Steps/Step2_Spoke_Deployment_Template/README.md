# Step 2: Spoke Deployment Template

## Overview
This step deploys spoke virtual networks and their associated subnets that will be managed by the Azure Network Manager created in Step 1. This provides a standardized approach to deploying new spoke networks that automatically become part of the hub and spoke architecture with proper routing and security configurations.

## Resources Deployed
- **Resource Groups**: One for each spoke defined in the configuration
- **Virtual Networks**: Spoke VNets with addresses automatically allocated from the IPAM pool
- **Subnets**: Subnets within each spoke VNet as defined in configuration
- **Network Manager Integration**:
  - Automatic association with regional network groups
  - IP address allocation from the proper IPAM pool
  - Inherited connectivity and routing configurations from the Network Manager

## Naming Conventions
The deployment follows these naming conventions:
- **Resource Groups**: Based on the spoke name provided in variables
- **VNets**: Named according to the vnet name specified in each spoke configuration
- **Subnets**: Named according to the subnet name specified in each VNet configuration

## How It Works
1. **Remote State Access**: The deployment retrieves required information from the Network Manager deployment's Terraform state
2. **Spoke Resources Creation**:
   - Resource groups are created for each spoke
   - VNets are provisioned with IP addresses automatically allocated from the appropriate IPAM pools
   - Subnets are created within each VNet
3. **Network Manager Integration**:
   - VNets are automatically added to the correct regional network group
   - Connectivity configurations from Step 1 are applied, creating hub and spoke connections
   - Routing configurations are applied to ensure proper traffic flow through firewalls

## Cross-Subscription Support
- The deployment supports deploying spokes in a different subscription than where Network Manager resides
- The `network_manager_subscription_id` variable specifies where to find Network Manager
- The `subscription_id` variable specifies where to deploy the spoke resources

## Prerequisites
- Completed Step 1 (Network Manager Deployment)
- Storage account access to read the Terraform state from Step 1
- Proper permissions in the target subscription(s)

## Customization
This template can be adapted for different environments by:
- Modifying the number and configuration of spokes
- Adjusting subnet configurations based on workload requirements
- Deploying to different regions supported by your Network Manager

## Getting Started
1. Copy `backend.tf.example` to `backend.tf` and fill in your storage account details
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and customize variables
3. Run `terraform init` to initialize the deployment
4. Run `terraform plan` to preview changes
5. Run `terraform apply` to deploy the resources 