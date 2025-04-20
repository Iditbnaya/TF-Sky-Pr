variable "name" {
  description = "The name of the firewall"
  type = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Bastion name must be between 1 and 80 characters."
  }
}

variable "region" {
  description = "The region of the firewall"
  type = string
  
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.region))
    error_message = "Region must be a valid Azure region name."
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

variable "subnet_id" {
  description = "The ID of the subnet"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[a-zA-Z0-9_-]+/providers/Microsoft\\.Network/virtualNetworks/[a-zA-Z0-9_-]+/subnets/[a-zA-Z0-9_-]+$", var.subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID for a subnet resource."
  }
}
