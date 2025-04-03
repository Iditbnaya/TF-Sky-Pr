variable "subscription_id" {
  description = "The subscription ID"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "The subscription_id must be a valid UUID."
  }
}

variable "region" {
  description = "The region"
  type        = string
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.region))
    error_message = "The region must be a valid Azure region name."
  }
}

variable "tags" {
  description = "The tags"
  type        = map(string)
}

variable "network_manager_resource_group_name" {
  description = "The name of the resource group of the network manager"
  type        = string
  validation {
    condition     = length(var.network_manager_resource_group_name) >= 1 && length(var.network_manager_resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "network_manager" {
  description = "The network manager"
  type = object({
    name              = string,
    scope_accesses    = list(string),
    management_groups = list(string),
    subscriptions     = list(string)
  })

  validation {
    condition     = length(var.network_manager.name) >= 1 && length(var.network_manager.name) <= 80
    error_message = "Network manager name must be between 1 and 80 characters."
  }

  validation {
    condition     = length(var.network_manager.scope_accesses) > 0
    error_message = "At least one scope access must be provided."
  }

  validation {
    condition = alltrue([for access in var.network_manager.scope_accesses :
    contains(["Connectivity", "SecurityAdmin", "SecurityUser", "Routing"], access)])
    error_message = "Scope accesses must be one of: Connectivity, SecurityAdmin, SecurityUser, Routing."
  }
}

variable "ipam_pools" {
  description = "List of IPAM pool configurations"
  type = list(object({
    name             = string,
    address_prefixes = list(string),
    region           = string,
    hub_pool = object({
      name             = string,
      address_prefixes = list(string)
    }),
    spoke_pools = object({
      name             = string,
      address_prefixes = list(string)
    }),
    monitoring_pool = optional(object({
      name             = string,
      address_prefixes = list(string)
    }))
  }))

  validation {
    condition     = length(var.ipam_pools) > 0
    error_message = "At least one IPAM pool must be provided."
  }

  validation {
    condition     = alltrue([for pool in var.ipam_pools : 
                    can(regex("^[a-z]+[a-z0-9]*$", pool.region))])
    error_message = "All IPAM pool regions must be valid Azure region names."
  }

  validation {
    condition     = alltrue([for pool in var.ipam_pools : 
                    alltrue([for prefix in pool.address_prefixes : 
                    can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", prefix))])])
    error_message = "All IPAM pool address prefixes must be valid CIDR notation."
  }
}

variable "existing_hubs" {
  description = "List of existing hub configurations by region"
  type = list(object({
    resource_group_name = string,
    vnet_name          = string,
    fw_name            = string,
    region             = string
  }))

  validation {
    condition     = length(var.existing_hubs) > 0
    error_message = "At least one existing hub must be provided."
  }

  validation {
    condition     = alltrue([for hub in var.existing_hubs : 
                    can(regex("^[a-z]+[a-z0-9]*$", hub.region))])
    error_message = "All hub regions must be valid Azure region names."
  }
}