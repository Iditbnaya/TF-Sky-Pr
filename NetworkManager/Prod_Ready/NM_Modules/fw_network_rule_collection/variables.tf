variable "name" {
  description = "The name of the network rule collection"
  type = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Network rule collection name must be between 1 and 80 characters."
  }
}

variable "azure_firewall_name" {
  description = "The name of the Azure Firewall"
  type = string
  
  validation {
    condition     = length(var.azure_firewall_name) >= 1 && length(var.azure_firewall_name) <= 80
    error_message = "Azure Firewall name must be between 1 and 80 characters."
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

variable "priority" {
  description = "The priority of the network rule collection"
  type = number
  
  validation {
    condition     = var.priority >= 100 && var.priority <= 65000
    error_message = "Priority must be between 100 and 65000."
  }
}

variable "action" {
  description = "The action of the network rule collection"
  type = string
  
  validation {
    condition     = contains(["Allow", "Deny"], var.action)
    error_message = "Action must be either 'Allow' or 'Deny'."
  }
}

variable "rules" {
  description = "The rules of the network rule collection"
  type = list(object({
    name = string
    source_addresses = optional(list(string))
    source_ip_groups = optional(list(string))
    destination_addresses = optional(list(string))
    destination_ip_groups = optional(list(string))
    destination_fqdns = optional(list(string))
    destination_ports = list(string)
    protocols = list(string)
  }))
  
  validation {
    condition     = length(var.rules) > 0
    error_message = "At least one rule must be provided."
  }
  
  validation {
    condition     = alltrue([for rule in var.rules : 
                    (rule.source_addresses != null || rule.source_ip_groups != null) && 
                    (rule.destination_addresses != null || rule.destination_ip_groups != null || rule.destination_fqdns != null)])
    error_message = "Each rule must specify at least one source (addresses or IP groups) and one destination (addresses, IP groups, or FQDNs)."
  }
  
  validation {
    condition     = alltrue([for rule in var.rules : 
                    length(rule.destination_ports) > 0])
    error_message = "Each rule must specify at least one destination port."
  }
  
  validation {
    condition     = alltrue([for rule in var.rules : 
                    length(rule.protocols) > 0])
    error_message = "Each rule must specify at least one protocol."
  }
  
  validation {
    condition     = alltrue(flatten([for rule in var.rules : 
                    [for protocol in rule.protocols : 
                    contains(["TCP", "UDP", "ICMP", "Any"], protocol)]]))
    error_message = "Protocol must be one of: TCP, UDP, ICMP, or Any."
  }
}

variable "tags" {
  description = "The tags of the network rule collection"
  type = map(string)
  default = {}
}

