variable "name" {
  description = "The name of the firewall"
  type = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Firewall name must be between 1 and 80 characters."
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

variable "is_public_ip" {
  description = "Whether the firewall has a public IP address"
  type = bool
  default = false
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type = string
  
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/resourceGroups/[a-zA-Z0-9_-]+/providers/Microsoft\\.Network/virtualNetworks/[a-zA-Z0-9_-]+/subnets/[a-zA-Z0-9_-]+$", var.subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID for a subnet resource."
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

variable "sku_name" {
  description = "The name of the SKU"
  type = string
  default = "AZFW_VNet"
  
  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.sku_name)
    error_message = "SKU name must be one of: AZFW_VNet, AZFW_Hub."
  }
}

variable "sku_tier" {
  description = "The tier of the SKU"
  type = string
  default = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium", "Basic"], var.sku_tier)
    error_message = "SKU tier must be one of: Standard, Premium, Basic."
  }
}





