variable "name" {
  description = "The name of the IPAM pool"
  type = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "IPAM pool name must be between 1 and 80 characters."
  }
}

variable "region" {
  description = "The region of the IPAM pool"
  type = string
  
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.region))
    error_message = "Region must be a valid Azure region name."
  }
}

variable "tags" {
  description = "The tags of the IPAM pool"
  type = map(string)
}

variable "network_manager_id" {
  description = "The ID of the network manager"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/networkManagers/[^/]+$", var.network_manager_id))
    error_message = "Network manager ID must be a valid Azure resource ID for a network manager resource."
  }
}

variable "address_prefixes" {
  description = "The address prefixes of the IPAM pool"
  type = list(string)
  
  validation {
    condition     = length(var.address_prefixes) > 0
    error_message = "At least one address prefix must be provided."
  }
  
  validation {
    condition     = alltrue([for prefix in var.address_prefixes : can(cidrnetmask(prefix))])
    error_message = "Address prefixes must be valid CIDR notation."
  }
}

variable "hub_pool" {
  description = "The hub pool of the IPAM pool"
  type = object({
    name = string,
    address_prefixes = list(string)
  })
  
  validation {
    condition     = length(var.hub_pool.name) >= 1 && length(var.hub_pool.name) <= 80
    error_message = "Hub pool name must be between 1 and 80 characters."
  }
  
  validation {
    condition     = length(var.hub_pool.address_prefixes) > 0
    error_message = "At least one address prefix must be provided for the hub pool."
  }
  
  validation {
    condition     = alltrue([for prefix in var.hub_pool.address_prefixes : can(cidrnetmask(prefix))])
    error_message = "Hub pool address prefixes must be valid CIDR notation."
  }
}

variable "monitoring_pool" {
  description = "The monitoring pool of the IPAM pool"
  type = object({
    name = string,
    address_prefixes = list(string)
  })
  
  validation {
    condition     = length(var.monitoring_pool.name) >= 1 && length(var.monitoring_pool.name) <= 80
    error_message = "Monitoring pool name must be between 1 and 80 characters."
  }
  
  validation {
    condition     = length(var.monitoring_pool.address_prefixes) > 0
    error_message = "At least one address prefix must be provided for the monitoring pool."
  }
  
  validation {
    condition     = alltrue([for prefix in var.monitoring_pool.address_prefixes : can(cidrnetmask(prefix))])
    error_message = "Monitoring pool address prefixes must be valid CIDR notation."
  }
}

variable "spoke_pools" {
  description = "The spoke pools of the IPAM pool"
  type = object({
    name = string,
    address_prefixes = list(string)
  })
  
  validation {
    condition     = length(var.spoke_pools.name) >= 1 && length(var.spoke_pools.name) <= 80
    error_message = "Spoke pool name must be between 1 and 80 characters."
  }
  
  validation {
    condition     = length(var.spoke_pools.address_prefixes) > 0
    error_message = "At least one address prefix must be provided for the spoke pool."
  }
  
  validation {
    condition     = alltrue([for prefix in var.spoke_pools.address_prefixes : can(cidrnetmask(prefix))])
    error_message = "Spoke pool address prefixes must be valid CIDR notation."
  }
}
