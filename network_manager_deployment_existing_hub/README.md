# Network Manager Deployment (Existing Hub)

This module creates the core Azure Network Manager resources for an existing hub and spoke network topology. It functions as **Component 1** in the deployment workflow and generates outputs that are required by the network_manager_usage module.

## Role in Deployment Sequence

```
Network Manager Deployment (This Module)
            ↓
      [Terraform State]
            ↓
    Network Manager Usage
```

This module is designed to be deployed first and creates the foundational resources that will be referenced by the network_manager_usage module:

1. Network Manager with scope access configuration
2. IPAM pool hierarchy for each region
3. References to existing hub networks and firewalls
4. Initial spoke networks (if configured)
5. Routing and connectivity configurations

## Features

- Creates a Network Manager instance with specified scope accesses
- Sets up IPAM pools for managing IP addresses across multiple regions
- Connects to existing hub VNets with Azure Firewalls
- Creates initial spoke VNets connected to the existing hubs
- Configures connectivity and routing through the hub firewalls
- Exports outputs required by the network_manager_usage module

## Resource Naming Convention

All resources deployed by this module use the naming convention managed by the naming module. The naming module standardizes resource names as follows:

`<resource-type-prefix>-<sanitized-name>-<region-abbreviation>[-random-suffix]`

Where:
- **resource-type-prefix**: Automatically determined based on the Azure resource type (e.g., "rg", "vnet", "snet")
- **sanitized-name**: The free text name YOU provide, cleaned of invalid characters
- **region-abbreviation**: Automatically converted from the full region name to its short abbreviation
- **random-suffix** (optional): A random string for ensuring global uniqueness

**Important**: When providing names in your configuration, you only need to specify the free text name component. The module will automatically add the appropriate prefix, region abbreviation, and handle any sanitization required.

## Prerequisites

Before using this module, you must have:

1. An existing Azure subscription
2. One or more existing hub virtual networks with Azure Firewalls
3. Appropriate permissions to create Network Manager resources

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

   A `terraform.tfvars.example` file is provided as a template with placeholder values. Copy this file to `terraform.tfvars` and replace the placeholders with your actual values before deployment. The example file includes all required variables with appropriate structure.

3. **Deploy the Infrastructure**
   ```bash
   terraform apply
   ```

4. **Post-Deployment Steps**

   a. **Associate your VNets with their corresponding IPAM pools (MANUAL STEP REQUIRED):**
   - Log in to the Azure Portal
   - For each hub VNet:
     - Navigate to the existing hub VNet
     - Go to "Settings" → "IP Address Management (IPAM)"
     - Select the corresponding hub IPAM pool created for that region
     - Click "Assign"
   - For any monitoring VNets:
     - Navigate to the monitoring VNet
     - Go to "Settings" → "IP Address Management (IPAM)"
     - Select the corresponding monitoring IPAM pool created for that region
     - Click "Assign"

   > **Important Note**: Currently, there is no automated way to associate existing VNets with IPAM pools through Terraform. This must be done manually for all existing hub and monitoring VNets after deployment.

   b. **Enable the routing configuration in the Network Manager:**
   - Navigate to the Network Manager resource
   - Go to "Configurations" → "Routing configurations"
   - Select the created routing configuration 
   - Click on "Deploy to network"
   - Select the appropriate network group and click "Deploy"

## Critical Outputs for network_manager_usage

This module produces the following critical outputs that are required by the network_manager_usage module:

1. `network_manager_id` - The ID of the Network Manager
2. `ipam_pools` - Map of IPAM pool IDs by region
3. `hub_vnet_ids` - Map of hub virtual network IDs by region
4. `fw_private_ip` - Map of firewall private IP addresses by region

These outputs are accessed by the network_manager_usage module through the terraform_remote_state data source.

## Variable Structure

### Required Variables

```hcl
# Azure subscription ID (required)
subscription_id = "00000000-0000-0000-0000-000000000000"

# Primary Azure region for deployment (required)
region = "israelcentral"

# Tags to apply to all resources (optional)
tags = {
  Environment = "Dev"
  Project     = "NetworkManager"
  Owner       = "DevOps"
}

# Resource group for Network Manager (required)
network_manager_resource_group_name = "network-manager-rg"
```

### Network Manager Configuration

```hcl
network_manager = {
  name              = "network-manager"                     # Name of the Network Manager
  scope_accesses    = ["Connectivity", "SecurityAdmin", "Routing"]  # Access types
  management_groups = []                                   # Management group GUIDs to manage (optional)
  subscriptions     = ["00000000-0000-0000-0000-000000000000"]    # Subscription GUIDs to manage
}
```

### IPAM Pool Configurations for Multiple Regions

```hcl
# IPAM pools configuration with hierarchical structure for multiple regions
ipam_pools = [
  {
    name             = "region1-pool"                      # Parent IPAM pool name for first region
    address_prefixes = ["10.0.0.0/8"]                      # Valid CIDR notation required
    region           = "westeurope"                        # Region for the IPAM pool
    
    # Hub IPAM pool (allocated from parent)
    hub_pool = {
      name = "hub",
      # IMPORTANT: For existing hub deployments, these address prefixes MUST match 
      # the address space of your existing hub VNet
      address_prefixes = ["10.20.0.0/16"]
    }
    
    # Spoke IPAM pool (allocated from parent)
    spoke_pools = {
      name             = "spokes",
      address_prefixes = ["10.128.0.0/9"]
    }
    
    # Optional Monitoring IPAM pool (allocated from parent)
    monitoring_pool = {
      name             = "monitoring",
      address_prefixes = ["10.10.0.0/16"]
    }
  },
  {
    name             = "region2-pool"                      # Parent IPAM pool name for second region
    address_prefixes = ["11.0.0.0/8"]                      # Valid CIDR notation required
    region           = "northeurope"                       # Region for the IPAM pool
    
    # Hub IPAM pool (allocated from parent)
    hub_pool = {
      name = "hub",
      # IMPORTANT: For existing hub deployments, these address prefixes MUST match 
      # the address space of your existing hub VNet in the second region
      address_prefixes = ["11.20.0.0/16"]
    }
    
    # Spoke IPAM pool (allocated from parent)
    spoke_pools = {
      name             = "spokes",
      address_prefixes = ["11.128.0.0/9"]
    }
    
    # Monitoring IPAM pool (allocated from parent)
    monitoring_pool = {
      name             = "monitoring",
      address_prefixes = ["11.10.0.0/16"]
    }
  }
]
```

### Existing Hub Configurations for Multiple Regions

```hcl
# Existing hub VNet configurations for multiple regions
existing_hubs = [
  {
    region              = "westeurope"
    resource_group_name = "rg-hub-westeurope"
    vnet_name           = "vnet-hub-westeurope"
    fw_name             = "fw-hub-westeurope"
  },
  {
    region              = "northeurope"
    resource_group_name = "rg-hub-northeurope"
    vnet_name           = "vnet-hub-northeurope"
    fw_name             = "fw-hub-northeurope"
  }
]
```

### Spoke Network Configuration

```hcl
# Spoke network configurations by region
spoke = [
  {
    region = "israelcentral"
    resource_group_name = "spokes-israel"
    vnets = [
      {
        name        = "spoke1"
        subnet_mask = 16
        subnets = [
          {
            name        = "subnet1"
            subnet_mask = 24
          },
          {
            name        = "subnet2"
            subnet_mask = 24
          }
        ]
      }
    ]
  },
  {
    region = "swedencentral"
    resource_group_name = "spokes-sweden"
    vnets = [
      {
        name        = "spoke1"
        subnet_mask = 16
        subnets = [
          {
            name        = "subnet1"
            subnet_mask = 24
          }
        ]
      }
    ]
  }
]
```

## Multi-Region Support

This module fully supports multiple regions through:

1. **Region-Specific IPAM Pools:**
   - Each region can have its own IPAM pool hierarchy
   - Address spaces are managed independently per region
   - Supports hub, spoke, and monitoring pools per region

2. **Region-Specific Spoke Networks:**
   - Spoke networks can be created in different regions
   - Each region's spokes are managed by a dedicated network group
   - Supports multiple spoke networks per region

3. **Region-Specific Routing:**
   - Each region has its own routing configuration
   - Routes are configured through the region's hub firewall
   - Supports cross-region communication through hub firewalls

4. **Existing Hub Support:**
   - Supports multiple existing hubs across regions
   - Each hub can have its own firewall and network configuration
   - Hubs are referenced by region for proper routing

## Next Steps: Using with network_manager_usage

After successfully deploying this module:

1. Verify all resources are correctly created in Azure
2. Complete the post-deployment steps to assign hub VNets to IPAM pools
3. Take note of the Terraform state file location, as it will be needed by network_manager_usage
4. Proceed to the network_manager_usage module to deploy additional spoke networks

The network_manager_usage module will reference the outputs from this deployment through the terraform_remote_state data source. It is critical that the regions specified in network_manager_usage match the regions configured in this deployment.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

# Existing Hub Deployment

This deployment scenario creates a Network Manager configuration for an existing hub and spoke network topology, where the hub network already exists.

## Prerequisites

1. An existing Azure subscription
2. One or more existing hub virtual networks with:
   - Azure Firewall deployed
   - Appropriate subnets configured
3. Appropriate permissions to create Network Manager resources

## Deployment Steps

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review and update the configuration:**
   - Copy `terraform.tfvars.example` to `terraform.tfvars`
   - Update the values in `terraform.tfvars` with your specific configuration
   - Ensure the hub address prefixes in the IPAM configuration match your existing hub VNet address spaces

3. **Deploy the Network Manager:**
   ```bash
   terraform apply -target="module.network_manager"
   ```

4. **Deploy the IPAM pool hierarchy:**
   ```bash
   terraform apply -target="module.ipam_pool_hierarchy"
   ```

5. **Deploy the spoke networks:**
   ```bash
   terraform apply -target="module.multi_region_spokes"
   ```

6. **Deploy the routing configuration:**
   ```bash
   terraform apply -target="module.multi_region_udr"
   ```

7. **Post-deployment steps:**

   a. **Assign the existing hub VNets to the created hub IPAM pools:**
   - Log in to the Azure Portal
   - Navigate to each existing hub VNet
   - Go to "Settings" → "IP Address Management (IPAM)"
   - Select the corresponding hub IPAM pool for that region
   - Click "Assign"

   b. **Enable the routing configuration in the Network Manager:**
   - Navigate to the Network Manager resource
   - Go to "Configurations" → "Routing configurations"
   - Select the created routing configuration 
   - Click on "Deploy to network"
   - Select the appropriate network group and click "Deploy"

## Variable Structure

### Required Variables

```hcl
# Azure subscription ID (required)
subscription_id = "00000000-0000-0000-0000-000000000000"

# Primary Azure region for deployment (required)
region = "israelcentral"

# Tags to apply to all resources (optional)
tags = {
  Environment = "Dev"
  Project     = "NetworkManager"
  Owner       = "DevOps"
}

# Resource group for Network Manager (required)
network_manager_resource_group_name = "network-manager-rg"
```

### Network Manager Configuration

```hcl
network_manager = {
  name              = "nm"                                  # Name of the Network Manager
  scope_accesses    = ["Connectivity", "SecurityAdmin", "Routing"]  # Access types
  management_groups = []                                   # Management groups to manage (optional)
  subscriptions     = []                                   # Subscriptions to manage (optional)
}
```

### IPAM Pool Configurations

```hcl
# IPAM pools configuration with hierarchical structure for multiple regions
ipam_pools = [
  {
    name             = "parent-ipam"                        # Parent IPAM pool name
    address_prefixes = ["10.0.0.0/8"]                       # Valid CIDR notation required
    region           = "israelcentral"                      # Region for the IPAM pool
    
    # Hub IPAM pool (allocated from parent)
    hub_pool = {
      name = "hub"
      # IMPORTANT: For existing hub deployments, these address prefixes MUST match 
      # the address space of your existing hub VNet
      address_prefixes = ["10.1.0.0/16", "10.20.0.0/16"]
    }
    
    # Spoke IPAM pool (allocated from parent)
    spoke_pools = {
      name             = "spokes"
      address_prefixes = ["10.128.0.0/9"]
    }

    # Monitoring IPAM pool (allocated from parent)
    monitoring_pool = {
      name             = "monitoring"
      address_prefixes = ["10.64.0.0/10"]
    }
  },
  {
    name             = "parent-ipam"                        # Parent IPAM pool name
    address_prefixes = ["172.16.0.0/12"]                    # Valid CIDR notation required
    region           = "swedencentral"                      # Region for the IPAM pool
    
    # Hub IPAM pool (allocated from parent)
    hub_pool = {
      name = "hub"
      # IMPORTANT: For existing hub deployments, these address prefixes MUST match 
      # the address space of your existing hub VNet
      address_prefixes = ["172.16.0.0/16"]
    }
    
    # Spoke IPAM pool (allocated from parent)
    spoke_pools = {
      name             = "spokes"
      address_prefixes = ["172.18.0.0/15"]
    }

    # Monitoring IPAM pool (allocated from parent)
    monitoring_pool = {
      name             = "monitoring"
      address_prefixes = ["172.20.0.0/16"]
    }
  }
]
```

### Existing Hub Configuration

```hcl
# Existing hub VNet configurations for multiple regions
existing_hubs = [
  {
    region              = "westeurope"
    resource_group_name = "rg-hub-westeurope"
    vnet_name           = "vnet-hub-westeurope"
    fw_name             = "fw-hub-westeurope"
  },
  {
    region              = "northeurope"
    resource_group_name = "rg-hub-northeurope"
    vnet_name           = "vnet-hub-northeurope"
    fw_name             = "fw-hub-northeurope"
  }
]
```

### Spoke Network Configurations

```hcl
# Spoke network configurations by region
spoke = [
  {
    resource_group_name = "spokes-israel"                # Resource group for spoke networks
    region              = "israelcentral"                # Region for the spoke resources
    vnets = [
      {
        name        = "spoke1"                      # First spoke network
        subnet_mask = 16                            # Subnet mask for the VNet
        subnets = [
          {
            name        = "subnet1"
            subnet_mask = 24
          },
          {
            name        = "subnet2"
            subnet_mask = 24
          }
        ]
      }
    ]
  },
  {
    resource_group_name = "spokes-sweden"              # Resource group for spoke networks
    region              = "swedencentral"              # Region for the spoke resources
    vnets = [
      {
        name        = "spoke1"                    # First spoke network in Sweden
        subnet_mask = 16                          # Subnet mask for the VNet
        subnets = [
          {
            name        = "subnet1"
            subnet_mask = 24
          }
        ]
      }
    ]
  }
]
```

### Connectivity Configuration

```hcl
# Connectivity configuration
connectivity_config = {
  name = "HubAndSpoke"  # Name of the connectivity configuration
}
```

## Multi-Region Support

This deployment supports multiple regions through the following features:

1. **Region-Specific IPAM Pools:**
   - Each region can have its own IPAM pool hierarchy
   - Address spaces are managed independently per region
   - Supports hub, spoke, and monitoring pools per region

2. **Region-Specific Spoke Networks:**
   - Spoke networks can be created in different regions
   - Each region's spokes are managed by a dedicated network group
   - Supports multiple spoke networks per region

3. **Region-Specific Routing:**
   - Each region has its own routing configuration
   - Routes are configured through the region's hub firewall
   - Supports cross-region communication through hub firewalls

4. **Existing Hub Support:**
   - Supports multiple existing hubs across regions
   - Each hub can have its own firewall and network configuration
   - Hubs are referenced by region for proper routing

## Outputs

The deployment provides the following outputs:

- `resource_group_id`: ID of the Network Manager resource group
- `fw_private_ip`: Map of firewall private IP addresses by region
- `network_manager_id`: ID of the created Network Manager
- `network_manager_name`: Name of the created Network Manager
- `ipam_pools`: Map of IPAM pool IDs by region
- `spoke_network_groups`: Map of network group IDs by region
- `hub_vnet_ids`: Map of hub virtual network IDs by region
- `hub_fw_ids`: Map of hub firewall IDs by region

## Notes

- Ensure that the hub address prefixes in the IPAM configuration match your existing hub VNet
- The deployment supports multiple regions through the use of region-specific configurations
- Each region requires its own hub, spoke networks, and routing configuration
- Cross-region communication is handled through the hub firewalls
- The deployment uses the AzAPI provider for resource creation 