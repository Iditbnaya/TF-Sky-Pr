# Azure Network Manager Terraform

This repository provides Terraform configurations for deploying Azure Network Manager with three different deployment options:

1. **Full Deployment** (`full_deployment`) - Creates a complete hub-and-spoke network topology from scratch, including:
   - Network Manager resource
   - IPAM pool hierarchy
   - Hub VNet with Azure Firewall
   - Spoke VNets and connectivity configuration

2. **Existing Hub Deployment** (`existing_hub_deployment`) - Creates Network Manager resources using an existing hub VNet:
   - Network Manager resource
   - IPAM pool hierarchy
   - Connects to existing hub VNet with Azure Firewall
   - Creates spoke VNets connected to the existing hub

3. **Multi-part Deployment** - Split deployment approach with separate modules:
   - **Part 1** (`network_manager_deployment_existing_hub`) - Core Network Manager deployment with existing hub(s)
   - **Part 2** (`network_manager_usage`) - Additional spoke networks that depend on Part 1

## Component Relationships

The components in this repository follow a clear dependency path:

```
Option 1: Full Deployment
    - Creates everything from scratch in a single deployment

Option 2: Existing Hub Deployment
    - Uses existing hub VNet in a single deployment

Option 3: Multi-part Deployment
    - Part 1: Network Manager Deployment (Existing Hub)
              ↓
        [Terraform State]
              ↓
    - Part 2: Network Manager Usage
```

For the multi-part deployment option:
- **Part 1** must be completed first, generating a Terraform state that contains resource outputs
- **Part 2** depends entirely on the Terraform state from Part 1

## Resource Naming Convention

All resources deployed by this solution use a standardized naming convention managed by the naming module. Resource names follow this pattern:

`<resource-type-prefix>-<sanitized-name>-<region-abbreviation>[-random-suffix]`

Where:
- **resource-type-prefix**: Automatically determined based on the Azure resource type (e.g., "rg", "vnet", "snet")
- **sanitized-name**: The free text name YOU provide, cleaned of invalid characters
- **region-abbreviation**: Automatically converted from the full region name to its short abbreviation (e.g., "East US" becomes "eus")
- **random-suffix** (optional): A random string for ensuring global uniqueness when enabled

**Important**: When providing resource names in your configuration, you only need to specify the free text name component (the "sanitized-name" part). The module will automatically:
- Add the appropriate resource type prefix
- Convert the region to its standard abbreviation
- Handle any sanitization required for the specific resource type
- Add a random suffix if configured to do so

For example, if you specify:
```hcl
resource_group_name = "network-manager"
region = "East US"
```

The actual resource name created will be: `rg-networkmanager-eus`

## Repository Structure

```
.
├── README.md                                # This file
├── init-backend.ps1                         # PowerShell script to initialize backend storage
├── modules/                                 # Shared Terraform modules 
├── full_deployment/                         # Option 1: Complete hub-and-spoke deployment
│   ├── README.md                            # Detailed documentation
│   ├── main.tf                              # Main Terraform configuration
│   ├── variables.tf                         # Variable definitions
│   └── terraform.tfvars.example             # Example variable values
├── existing_hub_deployment/                 # Option 2: Deployment with existing hub VNet
│   ├── README.md                            # Detailed documentation
│   ├── main.tf                              # Main Terraform configuration
│   ├── variables.tf                         # Variable definitions
│   └── terraform.tfvars.example             # Example variable values
├── network_manager_deployment_existing_hub/ # Option 3-Part 1: Network Manager core deployment
│   ├── README.md                            # Detailed documentation
│   ├── main.tf                              # Main Terraform configuration  
│   ├── variables.tf                         # Variable definitions
│   └── terraform.tfvars.example             # Example variable values
└── network_manager_usage/                   # Option 3-Part 2: Additional resources
    ├── README.md                            # Detailed documentation
    ├── main.tf                              # Main Terraform configuration  
    ├── variables.tf                         # Variable definitions
    └── terraform.tfvars.example             # Example variable values
```

## Deployment Options in Detail

### Option 1: Full Deployment

The Full Deployment option is suitable when you want to create an entirely new network infrastructure including:

- Network Manager with full scope access configuration
- Hub Virtual Network with Azure Firewall and Bastion
- IPAM pool hierarchy for IP address management
- Spoke Virtual Networks with custom subnets
- Hub-and-spoke connectivity configuration
- Routing through the Azure Firewall

Use this option when starting from scratch and need a complete network topology with proper segmentation.

See [full_deployment/README.md](full_deployment/README.md) for detailed instructions.

### Option 2: Existing Hub Deployment

The Existing Hub Deployment option is suitable when you already have an established hub network with:

- An existing hub Virtual Network
- An existing Azure Firewall
- Properly configured subnets and routing

This option will:
- Create a Network Manager resource
- Set up IPAM pools with allocations for your existing hub
- Create spoke Virtual Networks that connect to your existing hub
- Configure proper routing through your existing Azure Firewall

Use this option when you need to integrate Azure Network Manager with an existing hub-and-spoke topology.

See [existing_hub_deployment/README.md](existing_hub_deployment/README.md) for detailed instructions.

### Option 3: Multi-part Deployment

The Multi-part Deployment option separates the deployment into two distinct phases:

#### Part 1: Network Manager Deployment (Existing Hub)

The first module creates the core Network Manager resources:
- Network Manager with scope access configuration
- IPAM pool hierarchy for each region
- References to existing hub networks and firewalls
- Initial spoke networks (if configured)
- Routing and connectivity configurations

This module exports outputs to Terraform state that will be used by Part 2.

See [network_manager_deployment_existing_hub/README.md](network_manager_deployment_existing_hub/README.md) for detailed instructions.

#### Part 2: Network Manager Usage

The second module depends on the successful deployment of Part 1 and uses its Terraform state to:
- Create additional spoke networks in regions defined in Part 1
- Connect new spokes to the existing hub networks
- Configure routing through the existing hub firewalls
- Add firewall rules to the existing Azure Firewalls

This approach is ideal for teams with separation of responsibilities, where one team manages core network architecture and another team deploys workloads.

See [network_manager_usage/README.md](network_manager_usage/README.md) for detailed instructions.

## Prerequisites

Before deploying any component, you need to set up:

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured
- [Terraform](https://www.terraform.io/downloads.html) (≥ 1.3.0) installed
- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) for running the setup script

## Shared Setup: Backend Storage Account

All components use Azure Storage for the Terraform state. Initialize it with the provided PowerShell script:

```powershell
# From the root directory
./init-backend.ps1 -SubscriptionId "your-subscription-id" `
                  -ResourceGroupName "tfstate-rg" `
                  -StorageAccountName "tfstatesa" `
                  -ContainerName "tfstate" `
                  -Region "eastus2"
```

This will:
1. Create a resource group for the storage
2. Create a storage account 
3. Create a blob container
4. Generate a `backend.conf` file for Terraform initialization

## Multi-Region Support

All deployment options support multiple regions through:

1. **Region-Specific IPAM Pools:** Each region can have its own IPAM pool hierarchy
2. **Region-Specific Spoke Networks:** Spoke networks can be created in different regions
3. **Region-Specific Routing:** Each region has its own routing configuration
4. **Existing Hub Support:** Supports multiple existing hubs across regions

IMPORTANT: For Option 3 (Multi-part Deployment), the regions specified in Part 2 must match regions already configured in Part 1.

## License

This project is licensed under the MIT License. See the LICENSE file for details. 