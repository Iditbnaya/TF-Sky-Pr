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

variable "spoke" {
  description = "List of spoke network configurations by region"
  type = list(object({
    region = string,
    spokes = list(object({
      resource_group_name = string,
      vnets = list(object({
        name        = string,
        subnet_mask = number,
        subnets = list(object({
          name        = string,
          subnet_mask = number
        }))
      }))
    }))
  }))

  validation {
    condition     = length(var.spoke) > 0
    error_message = "At least one spoke configuration must be provided."
  }

  validation {
    condition     = alltrue([for region_config in var.spoke : 
                    can(regex("^[a-z]+[a-z0-9]*$", region_config.region))])
    error_message = "All spoke regions must be valid Azure region names."
  }

  validation {
    condition     = alltrue([for region_config in var.spoke : 
                    alltrue([for spoke_config in region_config.spokes :
                    length(spoke_config.resource_group_name) >= 1 && length(spoke_config.resource_group_name) <= 90])])
    error_message = "Resource group names must be between 1 and 90 characters."
  }

  validation {
    condition     = alltrue([for region_config in var.spoke : 
                    alltrue([for spoke_config in region_config.spokes :
                    alltrue([for vnet in spoke_config.vnets : 
                    length(vnet.name) >= 1 && length(vnet.name) <= 80])])])
    error_message = "VNet names must be between 1 and 80 characters."
  }

  validation {
    condition     = alltrue([for region_config in var.spoke : 
                    alltrue([for spoke_config in region_config.spokes :
                    alltrue([for vnet in spoke_config.vnets : 
                    vnet.subnet_mask >= 8 && vnet.subnet_mask <= 29])])])
    error_message = "VNet subnet masks must be between 8 and 29."
  }

  validation {
    condition     = alltrue([for region_config in var.spoke : 
                    alltrue([for spoke_config in region_config.spokes :
                    alltrue([for vnet in spoke_config.vnets : 
                    length(vnet.subnets) > 0])])])
    error_message = "Each VNet must have at least one subnet."
  }

  validation {
    condition     = alltrue([for region_config in var.spoke : 
                    alltrue([for spoke_config in region_config.spokes :
                    alltrue([for vnet in spoke_config.vnets : 
                    alltrue([for subnet in vnet.subnets :
                    length(subnet.name) >= 1 && length(subnet.name) <= 80])])])])
    error_message = "Subnet names must be between 1 and 80 characters."
  }

  validation {
    condition     = alltrue([for region_config in var.spoke : 
                    alltrue([for spoke_config in region_config.spokes :
                    alltrue([for vnet in spoke_config.vnets : 
                    alltrue([for subnet in vnet.subnets :
                    subnet.subnet_mask >= 16 && subnet.subnet_mask <= 29])])])])
    error_message = "Subnet masks must be between 16 and 29."
  }
}

variable "fw_network_rule_collections" {
  description = "The firewall network rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      source_addresses      = optional(list(string))
      source_ip_groups      = optional(list(string))
      destination_addresses = optional(list(string))
      destination_ip_groups = optional(list(string))
      destination_fqdns     = optional(list(string))
      destination_ports     = list(string)
      protocols             = list(string)
    }))
  }))

  validation {
    condition = alltrue([for collection in var.fw_network_rule_collections :
    length(collection.name) >= 1 && length(collection.name) <= 80])
    error_message = "Network rule collection names must be between 1 and 80 characters."
  }

  validation {
    condition = alltrue([for collection in var.fw_network_rule_collections :
    collection.priority >= 100 && collection.priority <= 65000])
    error_message = "Priority must be between 100 and 65000."
  }

  validation {
    condition = alltrue([for collection in var.fw_network_rule_collections :
    contains(["Allow", "Deny"], collection.action)])
    error_message = "Action must be either 'Allow' or 'Deny'."
  }

  validation {
    condition = alltrue([for collection in var.fw_network_rule_collections :
    length(collection.rules) > 0])
    error_message = "Each rule collection must contain at least one rule."
  }

  validation {
    condition = alltrue(flatten([for collection in var.fw_network_rule_collections :
      [for rule in collection.rules :
        (rule.source_addresses != null || rule.source_ip_groups != null) &&
    (rule.destination_addresses != null || rule.destination_ip_groups != null || rule.destination_fqdns != null)]]))
    error_message = "Each rule must specify at least one source (addresses or IP groups) and one destination (addresses, IP groups, or FQDNs)."
  }

  validation {
    condition = alltrue(flatten([for collection in var.fw_network_rule_collections :
      [for rule in collection.rules :
        alltrue([for protocol in rule.protocols :
    contains(["TCP", "UDP", "ICMP", "Any"], protocol)])]]))
    error_message = "Protocol must be one of: TCP, UDP, ICMP, or Any."
  }

  default = []
}