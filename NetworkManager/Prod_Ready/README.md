# Azure Network Manager Terraform Deployment

## Overview
This repository contains a multi-step Terraform deployment that creates and manages a complex Azure network architecture using Azure Network Manager. The solution implements hub and spoke network topology with centralized management, automated IP address allocation, and standardized connectivity.

## Architecture
The architecture follows Azure best practices for enterprise-scale networking:

1. **Hub and Spoke Topology**: Centralized connectivity through hub networks with firewall inspection
2. **Centralized Management**: Azure Network Manager provides unified control across regions and subscriptions
3. **Automated IP Address Management**: Hierarchical IPAM pools ensure non-overlapping address spaces
4. **Cross-Subscription Support**: Resources can be deployed across multiple subscriptions
5. **Multi-Regional Design**: Supports deployment across multiple Azure regions

## Deployment Phases

### Step 0: Create Storage Account
The initial step creates the Azure Storage Account and Container that will be used to store Terraform state files for subsequent steps. This ensures state is stored centrally and securely.

**Resources Created**:
- Resource Group
- Storage Account
- Storage Container

**[Learn More About Step 0](Steps/Step0_CreateStorageAccount/README.md)**

### Step 1: Network Manager Deployment
This step deploys Azure Network Manager and associated resources that form the foundation of the network architecture. It establishes the IPAM pool hierarchy, network groups, and connectivity configurations.

**Resources Created**:
- Azure Network Manager
- IPAM Pool Hierarchy (Parent, Regional, Hub, Spoke, Monitoring pools)
- Network Groups
- Connectivity and Routing Configurations

**Important**: If you plan to use Management Groups as the scope for Network Manager, you must first register the Microsoft.Network provider at the management group level:
```
az provider register --namespace Microsoft.Network --management-group <management-group-id>
```

**[Learn More About Step 1](Steps/Step1_Network_Manager_Deployment/README.md)**

### Step 2: Spoke Deployment Template
This step provides a standardized template for deploying spoke networks that automatically integrate with the hub and spoke architecture defined in Step 1. It leverages the Network Manager's centralized configurations.

**Resources Created**:
- Spoke Resource Groups
- Virtual Networks with automatic address allocation
- Subnets with predefined configurations

**[Learn More About Step 2](Steps/Step2_Spoke_Deployment_Template/README.md)**

## Module Structure
The deployment leverages a set of custom Terraform modules located in the `NM_Modules/` directory. These modules abstract complex configurations and provide reusable components:

- **resource_group**: Creates Azure resource groups
- **network_manager**: Deploys and configures Azure Network Manager
- **ipam_pool**: Creates and manages IPAM pools
- **ipam_pool_hierarchy_v2**: Builds hierarchical IPAM pool structures
- **naming**: Generates standardized resource names
- **connectivity_config**: Creates hub and spoke connectivity configurations
- **network_manager_routing**: Sets up routing configurations
- **spokes_v2**: Deploys and configures spoke networks

## Getting Started

1. **Clone the Repository**:
   ```
   git clone <repository-url>
   ```

2. **Deploy Step 0**:
   ```
   cd Prod_Ready/Steps/Step0_CreateStorageAccount
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   terraform init
   terraform apply
   ```

3. **Deploy Step 1**:
   ```
   cd ../Step1_Network_Manager_Deployment
   cp backend.tf.example backend.tf
   cp terraform.tfvars.example terraform.tfvars
   # Edit backend.tf and terraform.tfvars with your values
   
   # If using Management Groups, register the Microsoft.Network provider:
   az provider register --namespace Microsoft.Network --management-group <management-group-id>
   
   terraform init
   terraform apply
   ```

4. **Deploy Step 2**:
   ```
   cd ../Step2_Spoke_Deployment_Template
   cp backend.tf.example backend.tf
   cp terraform.tfvars.example terraform.tfvars
   # Edit backend.tf and terraform.tfvars with your values
   terraform init
   terraform apply
   ```

## Prerequisites
- Azure subscription(s) with owner/contributor permissions
- Terraform 1.0.0 or higher
- Azure CLI installed and configured
- For Management Group scoping: Ability to register providers at the management group level

## Contributing
Contributions to improve the deployment are welcome. Please feel free to submit pull requests or create issues for bugs and feature requests.

## License
This project is licensed under the MIT License - see the LICENSE file for details. 