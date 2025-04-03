variable "region" {
  description = "The region of the spoke"
  type = string
  
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.region))
    error_message = "Region must be a valid Azure region name."
  }
}

variable "tags" {
  description = "The tags of the spoke"
  type = map(string)
}

variable "resource_group_name" {
  description = "The name of the resource group of the spoke"
  type = string
  
  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "vnets" {
  description = "The vnets of the spoke"
  type = list(
      object({
        name                = string,
        subnet_mask         = number,
        subnets = list(object({
          name               = string,
          subnet_mask        = number,
          is_firewall_subnet = optional(bool),
          is_bastion_subnet  = optional(bool)
        }))
      })
    )
  
  validation {
    condition     = length(var.vnets) > 0
    error_message = "At least one vnet must be provided."
  }
  
  validation {
    condition     = alltrue([for vnet in var.vnets : 
                    length(vnet.name) >= 1 && length(vnet.name) <= 80])
    error_message = "Vnet names must be between 1 and 80 characters."
  }
  
  validation {
    condition     = alltrue([for vnet in var.vnets : 
                    vnet.subnet_mask >= 8 && vnet.subnet_mask <= 29])
    error_message = "Vnet subnet masks must be between 8 and 29."
  }
  
  validation {
    condition     = alltrue([for vnet in var.vnets : 
                    length(vnet.subnets) > 0])
    error_message = "At least one subnet must be provided for each vnet."
  }
  
  validation {
    condition     = alltrue(flatten([for vnet in var.vnets : [for subnet in vnet.subnets :
                    length(subnet.name) >= 1 && length(subnet.name) <= 80]]))
    error_message = "Subnet names must be between 1 and 80 characters."
  }
  
  validation {
    condition     = alltrue(flatten([for vnet in var.vnets : [for subnet in vnet.subnets :
                    subnet.subnet_mask >= 16 && subnet.subnet_mask <= 29]]))
    error_message = "Subnet masks must be between 16 and 29."
  }
}

variable "ipam_pool_id" {
  description = "The ID of the spokes IPAM pool"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/networkManagers/[^/]+/ipamPools/[^/]+$", var.ipam_pool_id))
    error_message = "IPAM pool ID must be a valid Azure resource ID for an IPAM pool resource."
  }
}

variable "network_manager_id" {
  description = "The ID of the network manager"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/networkManagers/[^/]+$", var.network_manager_id))
    error_message = "Network manager ID must be a valid Azure resource ID for a network manager resource."
  }
}

variable "hub_id" {
  description = "The ID of the hub"
  type = string
  default = null
  nullable = true
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.hub_id))
    error_message = "Hub ID must be a valid Azure resource ID for a virtual network resource."
  }
}

variable "fw_private_ip" {
  description = "The private IP address of the firewall"
  type = string
  default = null
  nullable = true

  validation {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", var.fw_private_ip))
    error_message = "Firewall private IP must be a valid IP address."
  }
}



