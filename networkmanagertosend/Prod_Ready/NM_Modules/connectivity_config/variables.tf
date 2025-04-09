variable "name" {
  description = "The name of the connectivity config"
  type = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Connectivity config name must be between 1 and 80 characters."
  }
}

variable "region" {
  description = "The region of the connectivity config"
  type = string
  
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.region))
    error_message = "Region must be a valid Azure region name."
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

variable "network_group_id" {
  description = "The ID of the network group"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/networkManagers/[^/]+/networkGroups/[^/]+$", var.network_group_id))
    error_message = "Network group ID must be a valid Azure resource ID for a network group resource."
  }
}

variable "hub_id" {
  description = "The ID of the hub"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.hub_id))
    error_message = "Hub ID must be a valid Azure resource ID for a virtual network resource."
  }
}

variable "delete_existing_peering" {
  description = "Whether to delete existing peerings"
  type = bool
  default = false
}

variable "is_global" {
  description = "Whether the connectivity config is global"
  type = bool
  default = false
}

variable "use_hub_gateway" {
  description = "Whether to use the hub gateway"
  type = bool
  default = false
}

variable "connectivity_topology" {
  description = "The connectivity topology"
  type = string
  default = "HubAndSpoke"
}

variable "group_connectivity" {
  description = "The group connectivity"
  type = string
  default = "None"
}


