variable "name" {
  description = "The name of the resource group"
  type        = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "IPAM pool name must be between 1 and 80 characters."
  }
}

variable "region" {
  description = "The Azure region for the resource group"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.region))
    error_message = "Region must be a valid Azure region name."
  }
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
} 

variable "address_prefixes" {
  description = "The address prefixes of the IPAM pool"
  type        = list(string)
  default     = []
  
  validation {
    condition     = var.address_prefixes == [] || alltrue([for prefix in var.address_prefixes : can(cidrnetmask(prefix))])
    error_message = "Address prefixes must be valid CIDR notation."
  }
}

variable "network_manager_id" {
  description = "The ID of the network manager"
  type        = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/networkManagers/[^/]+$", var.network_manager_id))
    error_message = "Network manager ID must be a valid Azure resource ID for a network manager resource."
  }
}

variable "is_child_pool" {
  description = "Whether the IPAM pool is a child pool"
  type        = bool
  default     = false
}

variable "parent_pool_name" {
  description = "The name of the parent pool"
  type        = string
  default     = ""
  
  validation {
    condition     = var.parent_pool_name == "" || (length(var.parent_pool_name) >= 1 && length(var.parent_pool_name) <= 80)
    error_message = "Parent pool name must be empty or between 1 and 80 characters."
  }
}


