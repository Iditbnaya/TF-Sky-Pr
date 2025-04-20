variable "name" {
  description = "The name of the subnet"
  type = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Subnet name must be between 1 and 80 characters."
  }
}

variable "region" {
  description = "The region of the subnet"
  type = string
  
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.region))
    error_message = "Region must be a valid Azure region name."
  }
}

variable "virtual_network_id" {
  description = "The ID of the virtual network"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.virtual_network_id))
    error_message = "Virtual network ID must be a valid Azure resource ID for a virtual network resource."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type = string
  
  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "subnet_mask" {
  description = "The subnet mask of the subnet"
  type = number
  
  validation {
    condition     = var.subnet_mask >= 16 && var.subnet_mask <= 29
    error_message = "Subnet mask must be between 16 and 29."
  }
}

variable "ipam_pool_id" {
  description = "The ID of the IPAM pool"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/networkManagers/[^/]+/ipamPools/[^/]+$", var.ipam_pool_id))
    error_message = "IPAM pool ID must be a valid Azure resource ID for an IPAM pool resource."
  }
}

variable "is_firewall_subnet" {
  description = "Whether the subnet is a firewall subnet"
  type = bool
  default = false
}

variable "is_bastion_subnet" {
  description = "Whether the subnet is a bastion subnet"
  type = bool
  default = false
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type = string
  
  validation {
    condition     = length(var.vnet_name) >= 1 && length(var.vnet_name) <= 80
    error_message = "Virtual network name must be between 1 and 80 characters."
  }
}
