variable "network_manager_id" {
  description = "The ID of the network manager"
  type        = string
}

variable "parent_ipam_pool_name" {
  description = "The name of the parent IPAM pool"
  type        = string
}

variable "parent_ipam_pool_address_prefix" {
  description = "The address prefix of the parent IPAM pool"
  type        = string
}

variable "regional_ipam_pool_address_prefix" {
  description = "The address prefix of the regional IPAM pool"
  type        = string
}

variable "regional_ipam_pool_hierarchy" {
  description = "Configuration for the regional IPAM pool hierarchy"
  type = object({
    name = string
    region = string
    hub_pool = object({
      name = string
      subnet_mask = optional(number, null)
      is_child_pool = optional(bool, true)
      address_prefix = optional(string, null)
    })
    spokes_pool = object({
      name = string
      subnet_mask = optional(number, null)
      is_child_pool = optional(bool, true)
      address_prefix = optional(string, null)
    })
    monitoring_pool = optional(object({
      name = string
      subnet_mask = optional(number, null)
      is_child_pool = optional(bool, true)
      address_prefix = optional(string, null)
    }), null)
  })
} 