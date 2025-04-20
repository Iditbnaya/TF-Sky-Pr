variable "name" {
  description = "The name of the virtual network"
  type = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Virtual network name must be between 1 and 80 characters."
  }
}

variable "region" {
  description = "The region of the virtual network"
  type = string
  
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.region))
    error_message = "Region must be a valid Azure region name."
  }
}

variable "tags" {
  description = "The tags of the virtual network"
  type = map(string)
}

variable "resource_group_id" {
  description = "The ID of the resource group"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+$", var.resource_group_id))
    error_message = "Resource group ID must be a valid Azure resource ID for a resource group."
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

variable "ipam_pool_id" {
  description = "The ID of the IPAM pool"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/networkManagers/[^/]+/ipamPools/[^/]+$", var.ipam_pool_id))
    error_message = "IPAM pool ID must be a valid Azure resource ID for an IPAM pool resource."
  }
}

variable "subnet_mask" {
  description = "The subnet mask of the vnet"
  type = number
  
  validation {
    condition     = var.subnet_mask >= 8 && var.subnet_mask <= 29
    error_message = "Subnet mask must be between 8 and 29."
  }
}

variable "subnets" {
  description = "The subnets of the vnet"
  type = list(object({
    name = string
    subnet_mask = number
    is_firewall_subnet = optional(bool, false)
    is_bastion_subnet = optional(bool, false)
  }))
  
  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet must be provided."
  }
  
  validation {
    condition     = alltrue([for subnet in var.subnets : 
                    length(subnet.name) >= 1 && length(subnet.name) <= 80])
    error_message = "Subnet names must be between 1 and 80 characters."
  }
  
  validation {
    condition     = alltrue([for subnet in var.subnets : 
                    subnet.subnet_mask >= 16 && subnet.subnet_mask <= 29])
    error_message = "Subnet masks must be between 16 and 29."
  }
}