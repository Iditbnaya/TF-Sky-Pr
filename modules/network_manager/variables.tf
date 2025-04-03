variable "name" {
  description = "The name of the resource group"
  type        = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Network manager name must be between 1 and 80 characters."
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

variable "scope_accesses" {
  description = "The network manager scope accesses"
  type        = list(string)
  default     = ["Connectivity", "SecurityAdmin", "Routing"]
  
  validation {
    condition     = length(var.scope_accesses) > 0
    error_message = "At least one scope access must be provided."
  }
  
  validation {
    condition     = alltrue([for access in var.scope_accesses : 
                    contains(["Connectivity", "SecurityAdmin", "SecurityUser", "Routing"], access)])
    error_message = "Scope accesses must be one of: Connectivity, SecurityAdmin, SecurityUser, Routing."
  }
}

variable "management_groups" {
  description = "The management groups to add as scopes of the network manager. Provide only the GUIDs of the management groups."
  type        = list(string)
  default     = []
  
  validation {
    condition     = alltrue([for mg in var.management_groups : 
                    can(regex("^[a-zA-Z0-9-_]+$", mg))])
    error_message = "Management group IDs must be valid GUIDs without the full resource path."
  }
}

variable "subscriptions" {
  description = "The subscriptions to add as scopes of the network manager. Provide only the GUIDs of the subscriptions."
  type        = list(string)
  default     = []
  
  validation {
    condition     = alltrue([for sub in var.subscriptions : 
                    can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", sub))])
    error_message = "Subscription IDs must be valid UUIDs without the full resource path."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  
  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

