variable "name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "sku" {
  description = "SKU of the key vault"
  type        = string
  default     = "standard"
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "Which resource group to deploy the Key Vault module to"
  type        = string
}

variable "location" {
  description = "Region of the resource"
  type        = string
  default     = "israelcentral"
}

variable "soft_delete_retention_days" {
  description = "Days to delete secret"
  type        = number
  default     = 90
}

variable "enable_rbac_authorization" {
  description = "Enable rbac authorization"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public access"
  type        = bool
  default     = false
}

variable "allow_bypass" {
  description = "Allowed bypass setting for network ACLs"
  type        = string
  default     = "AzureServices"
}

variable "default_action" {
  description = "Default action for network ACLs"
  type        = string
  default     = "Deny"
}

variable "ip_address_subnet_id" {
  description = "List of IP addresses or subnet IDs for network ACLs."
  type        = list(string)
  default     = []
}

# variable "subnet_id" {
#   description = "Subnet ID for the private endpoint"
#   type        = string
# }

# variable "dns_resource_group" {
#   description = "Name of the dns resource group"
#   type        = string
# }
variable "management_subscription_id" {
  description = "The ID of the management subscription"
  type        = string
  default     = ""
}

variable "enabled_for_deployment" {
  description = "Specifies whether the Key Vault can be used for deployment."
  type        = bool
  default     = true
    
}

variable "enabled_for_disk_encryption" {
  description = "Specifies whether the Key Vault can be used for disk encryption."
  type        = bool
  default     = true
}

variable "enabled_for_template_deployment" {
  description = "Specifies whether the Key Vault can be used for template deployment."
  type        = bool
  default     = true
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed through the firewall."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the Key Vault."
  type        = map(string)
  default     = {}
}