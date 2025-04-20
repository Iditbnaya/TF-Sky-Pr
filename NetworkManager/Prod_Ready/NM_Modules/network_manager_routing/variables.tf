variable "name" {
  description = "The name of the network manager routing config"
  type = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Routing configuration name must be between 1 and 80 characters."
  }
}

variable "region" {
  description = "The region of the network manager routing config"
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

variable "fw_private_ip" {
  description = "The private IP address of the firewall"
  type = string
  
  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.fw_private_ip))
    error_message = "Firewall private IP must be a valid IPv4 address."
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

