variable "subscription_id" {
  type = string
  description = "The Azure subscription ID where resources will be deployed"
  validation {
    condition     = can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", var.subscription_id))
    error_message = "The subscription_id must be a valid UUID in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

variable "regions" {
    type = list(string)
    description = "List of Azure regions where resources will be deployed"
    default = ["israelcentral", "swedencentral"]
    validation {
      condition     = length(var.regions) > 0
      error_message = "At least one region must be specified."
    }
    validation {
      condition     = alltrue([for region in var.regions : contains(["eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "southcentralus", "northcentralus", "westcentralus", "eastasia", "southeastasia", "japaneast", "japanwest", "australiaeast", "australiasoutheast", "australiacentral", "australiacentral2", "brazilsouth", "brazilsoutheast", "northeurope", "westeurope", "uksouth", "ukwest", "francecentral", "francesouth", "switzerlandnorth", "switzerlandwest", "germanynorth", "germanywestcentral", "norwayeast", "norwaywest", "canadacentral", "canadaeast", "southafricanorth", "southafricawest", "israelcentral", "indiawest", "indiacentral", "indiasouth", "jioindiacentral", "jioindiawest", "koreacentral", "koreasouth", "polandcentral", "uaenorth", "uaecentral", "swedencentral", "swedensouth", "qatarcentral", "mexicocentral", "malaysiawest", "italynorth", "chinaeast", "chinaeast2", "chinanorth", "chinanorth2", "germanywesto", "usdodeast", "usdodcentral", "usgovvirginia", "usgoviowa", "usgovarizona", "usgovtexas"], region)])
      error_message = "All regions must be valid Azure regions."
    }
}

variable "tags" {
    type = map(string)
    description = "Tags to apply to all deployed resources"
    default = {}
    validation {
      condition     = alltrue([for k, v in var.tags : length(k) <= 512 && length(v) <= 256])
      error_message = "Tag keys must be <= 512 characters and values must be <= 256 characters."
    }
}

variable "network_manager_config" {
    type = object({
      name = string
      region = string
      scope_accesses = list(string),
      management_groups = optional(list(string), []),
      subscriptions = optional(list(string), []),
      resource_group_name = string
    })
    description = "Configuration for the Azure Network Manager, including name, region, scope access and subscriptions"
    validation {
      condition     = can(regex("^[a-zA-Z0-9-_]{1,64}$", var.network_manager_config.name))
      error_message = "The network manager name must be 1-64 characters and can contain only letters, numbers, hyphens, and underscores."
    }
    validation {
      condition     = contains(["eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "southcentralus", "northcentralus", "westcentralus", "eastasia", "southeastasia", "japaneast", "japanwest", "australiaeast", "australiasoutheast", "australiacentral", "australiacentral2", "brazilsouth", "brazilsoutheast", "northeurope", "westeurope", "uksouth", "ukwest", "francecentral", "francesouth", "switzerlandnorth", "switzerlandwest", "germanynorth", "germanywestcentral", "norwayeast", "norwaywest", "canadacentral", "canadaeast", "southafricanorth", "southafricawest", "israelcentral", "indiawest", "indiacentral", "indiasouth", "jioindiacentral", "jioindiawest", "koreacentral", "koreasouth", "polandcentral", "uaenorth", "uaecentral", "swedencentral", "swedensouth", "qatarcentral", "mexicocentral", "malaysiawest", "italynorth", "chinaeast", "chinaeast2", "chinanorth", "chinanorth2", "germanywesto", "usdodeast", "usdodcentral", "usgovvirginia", "usgoviowa", "usgovarizona", "usgovtexas"], var.network_manager_config.region)
      error_message = "The region must be a valid Azure region."
    }
    validation {
      condition     = length(var.network_manager_config.scope_accesses) > 0
      error_message = "At least one scope access must be specified."
    }
    validation {
      condition     = alltrue([for scope in var.network_manager_config.scope_accesses : contains(["Connectivity", "SecurityAdmin", "Routing"], scope)])
      error_message = "Scope accesses must be one of: 'Connectivity', 'SecurityAdmin', or 'Routing'."
    }
    validation {
      condition     = alltrue([for sub in var.network_manager_config.subscriptions : can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", sub))])
      error_message = "All subscription IDs must be valid UUIDs in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
    }
    validation {
      condition     = can(regex("^[a-zA-Z0-9-_]{1,90}$", var.network_manager_config.resource_group_name))
      error_message = "Resource group name must be between 1 and 90 characters, and can contain only letters, numbers, hyphens, and underscores."
    }
}

variable "parent_ipam_pool_config" {
  type = object({
    name = string
    address_prefix = optional(string, "10.0.0.0")
    address_subnet_mask = optional(number, 8)
  })
  description = "Configuration for the parent IP Address Management (IPAM) pool that will be used as the base for all subnet allocations"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,64}$", var.parent_ipam_pool_config.name))
    error_message = "The IPAM pool name must be 1-64 characters and can contain only letters, numbers, hyphens, and underscores."
  }
  validation {
    condition     = can(cidrhost("${var.parent_ipam_pool_config.address_prefix}/${var.parent_ipam_pool_config.address_subnet_mask}", 0))
    error_message = "The address_prefix must be a valid IP address and address_subnet_mask must be a valid subnet mask."
  }
  validation {
    condition     = var.parent_ipam_pool_config.address_subnet_mask >= 8 && var.parent_ipam_pool_config.address_subnet_mask <= 30
    error_message = "The address_subnet_mask must be between 8 and 30."
  }
}

variable "regional_subnet_masks" {
  type = number
  description = "CIDR subnet mask to use for regional network allocations"
  default = 11
  validation {
    condition     = var.regional_subnet_masks >= 8 && var.regional_subnet_masks <= 30
    error_message = "The regional_subnet_masks must be between 8 and 30."
  }
}

variable "ipam_pool_hierarchy" {
  type = list(object({
    name = string
    region = string
    hub_pool = object({
      name = string
      subnet_mask = optional(number, 24)
      is_child_pool = optional(bool, true)
      address_prefix = optional(string, null)
    })
    spokes_pool = object({
      name = string
      subnet_mask = optional(number, 24)
      is_child_pool = optional(bool, true)
      address_prefix = optional(string, null)
    })
    monitoring_pool = optional(object({
      name = string
      subnet_mask = optional(number, 24)
      is_child_pool = optional(bool, true)
      address_prefix = optional(string, null)
    }), null)
  }))
  description = "Hierarchical configuration of IPAM pools for each region, including hub, spokes and optional monitoring pools"
  
  
}

variable "existing_hubs_info" {
    type = list(object({
        name = string
        region = string
        vnet_id = string
        fw_private_ip = string
    }))
    description = "Information about existing hub VNets that will be connected to the Network Manager, including firewall private IPs for routing"
    validation {
      condition     = alltrue([for hub in var.existing_hubs_info : contains(["eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "southcentralus", "northcentralus", "westcentralus", "eastasia", "southeastasia", "japaneast", "japanwest", "australiaeast", "australiasoutheast", "australiacentral", "australiacentral2", "brazilsouth", "brazilsoutheast", "northeurope", "westeurope", "uksouth", "ukwest", "francecentral", "francesouth", "switzerlandnorth", "switzerlandwest", "germanynorth", "germanywestcentral", "norwayeast", "norwaywest", "canadacentral", "canadaeast", "southafricanorth", "southafricawest", "israelcentral", "indiawest", "indiacentral", "indiasouth", "jioindiacentral", "jioindiawest", "koreacentral", "koreasouth", "polandcentral", "uaenorth", "uaecentral", "swedencentral", "swedensouth", "qatarcentral", "mexicocentral", "malaysiawest", "italynorth", "chinaeast", "chinaeast2", "chinanorth", "chinanorth2", "germanywesto", "usdodeast", "usdodcentral", "usgovvirginia", "usgoviowa", "usgovarizona", "usgovtexas"], hub.region)])
      error_message = "All regions in existing_hubs_info must be valid Azure regions."
    }
    validation {
      condition     = alltrue([for hub in var.existing_hubs_info : can(regex("^/subscriptions/[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+$", hub.vnet_id))])
      error_message = "The vnet_id must be a valid Azure resource ID for a Virtual Network."
    }
    validation {
      condition     = alltrue([for hub in var.existing_hubs_info : can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", hub.fw_private_ip))])
      error_message = "The fw_private_ip must be a valid IPv4 address."
    }
}

variable "network_group_environments" {
  type = list(string)
  description = "The environments to create the network group hierarchy for"
  default = ["dev", "preprod", "prod"]
}