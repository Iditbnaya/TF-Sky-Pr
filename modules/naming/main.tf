locals {
  # Lookup map of resource type prefixes
  resource_prefixes = {
    "resource_group"    = "rg"
    "virtual_network"   = "vnet"
    "subnet"            = "snet"
    "storage_account"   = "st"  # Special case due to naming restrictions
    "key_vault"         = "kv"
    "app_service"       = "app"
    "function_app"      = "func"
    "service_plan"      = "plan"
    "sql_server"        = "sql"
    "sql_database"      = "sqldb"
    "cosmos_account"    = "cosmos"
    "aks_cluster"       = "aks"
    "application_gateway" = "agw"
    "network_security_group" = "nsg"
    "route_table"       = "rt"
    "public_ip"         = "pip"
    "container_registry" = "acr"
    "load_balancer"     = "lb"
    "log_analytics"     = "log"
    "bastion_host"      = "bas"
    "nat_gateway"       = "nat"
    "firewall"          = "fw"
    "redis_cache"       = "redis"
    "api_management"    = "apim"
    "event_hub"         = "evh"
    "service_bus"       = "sb"
    "backup_vault"      = "bv"
    "vm"                = "vm"
    "disk"              = "disk"
    "nic"               = "nic"
    "availability_set"  = "avset"
  }
  

  
  # Map of Azure resource types to allowed characters regex patterns
  # Most resources follow general guidelines but some have specific restrictions
  allowed_chars_regex = {
    "default"          = "[^a-z0-9\\-]"
    "storage_account"  = "[^a-z0-9]"  # No hyphens allowed
    "container_registry" = "[^a-z0-9]" # No hyphens allowed
  }
  
  # Map of Azure resource name length constraints
  name_length_constraints = {
    "default"          = 63
    "storage_account"  = 24
    "key_vault"        = 24
    "app_service"      = 60
    "sql_server"       = 63
    "container_registry" = 50
  }
}

data "azurerm_location" "location" {
  location = var.region
}

resource "random_string" "random_suffix" {
  count = var.use_random_suffix ? 1 : 0

  length  = var.random_suffix_length
  upper   = false
  special = false
}

# Function to generate a standard resource name
# Format: <resource-type>-<sanitized-name>-<sanitized-region>
output "standard_name" {
  description = "Generates a standard resource name based on the provided parameters with sanitized inputs"
  value = var.use_random_suffix ? "${lookup(local.resource_prefixes, var.resource_type, var.resource_type)}-${replace(lower(var.name), local.allowed_chars_regex["default"], "")}-${replace(lower(var.az_region_abbr_map[data.azurerm_location.location.display_name]), local.allowed_chars_regex["default"], "")}-${random_string.random_suffix[0].result}" : "${lookup(local.resource_prefixes, var.resource_type, var.resource_type)}-${replace(lower(var.name), local.allowed_chars_regex["default"], "")}-${replace(lower(var.az_region_abbr_map[data.azurerm_location.location.display_name]), local.allowed_chars_regex["default"], "")}"
}

# Function for storage account name (special case)
# Storage accounts require lowercase, no hyphens, 24 char max
output "storage_account_name" {
  description = "Generates a storage account name - lowercase, no hyphens, 24 char max"
  value = var.use_random_suffix ? substr(
    "st${replace(lower(var.name), local.allowed_chars_regex["storage_account"], "")}${replace(lower(var.az_region_abbr_map[data.azurerm_location.location.display_name]), local.allowed_chars_regex["storage_account"], "")}${random_string.random_suffix[0].result}", 
    0, 
    24
  ) : substr(
    "st${replace(lower(var.name), local.allowed_chars_regex["storage_account"], "")}${replace(lower(var.az_region_abbr_map[data.azurerm_location.location.display_name]), local.allowed_chars_regex["storage_account"], "")}", 
    0, 
    24
  )
}

# Function for resources that can't have hyphens (like ACR)
output "no_hyphen_name" {
  description = "Generates a resource name without hyphens using clean inputs"
  value = var.use_random_suffix ? "${lookup(local.resource_prefixes, var.resource_type, var.resource_type)}${replace(lower(var.name), local.allowed_chars_regex["storage_account"], "")}${replace(lower(var.az_region_abbr_map[data.azurerm_location.location.display_name]), local.allowed_chars_regex["storage_account"], "")}${random_string.random_suffix[0].result}" : "${lookup(local.resource_prefixes, var.resource_type, var.resource_type)}${replace(lower(var.name), local.allowed_chars_regex["storage_account"], "")}${replace(lower(var.az_region_abbr_map[data.azurerm_location.location.display_name]), local.allowed_chars_regex["storage_account"], "")}"
}

# Function for resources with character limits
output "limited_length_name" {
  description = "Generates a resource name with a specified max length using clean inputs"
  value = var.use_random_suffix ? substr(
    "${lookup(local.resource_prefixes, var.resource_type, var.resource_type)}-${replace(lower(var.name), local.allowed_chars_regex["default"], "")}-${replace(lower(var.az_region_abbr_map[data.azurerm_location.location.display_name]), local.allowed_chars_regex["default"], "")}-${random_string.random_suffix[0].result}",
    0,
    lookup(local.name_length_constraints, var.resource_type, var.max_length)
  ) : substr(
    "${lookup(local.resource_prefixes, var.resource_type, var.resource_type)}-${replace(lower(var.name), local.allowed_chars_regex["default"], "")}-${replace(lower(var.az_region_abbr_map[data.azurerm_location.location.display_name]), local.allowed_chars_regex["default"], "")}",
    0,
    lookup(local.name_length_constraints, var.resource_type, var.max_length)
  )
} 