variable "resource_type" {
  description = "The type of resource to create a name for (e.g., 'resource_group', 'virtual_network', etc.)"
  type        = string
  
  validation {
    condition     = length(var.resource_type) > 0
    error_message = "Resource type cannot be empty."
  }
}

variable "name" {
  description = "The user-provided name component"
  type        = string
  
  validation {
    condition     = length(var.name) > 0
    error_message = "Name cannot be empty."
  }
}

variable "region" {
  description = "The Azure region where the resource will be deployed"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.region))
    error_message = "Region must be a valid Azure region name."
  }
}

variable "max_length" {
  description = "The maximum length for the resource name (for limited_length_name output)"
  type        = number
  default     = 63  # Default max length for most Azure resources
  
  validation {
    condition     = var.max_length >= 3 && var.max_length <= 256
    error_message = "Maximum length must be between 3 and 256 characters."
  }
} 

variable "random_suffix_length" {
  description = "The length of the random suffix"
  type        = number
  default     = 4
  
  validation {
    condition     = var.random_suffix_length >= 0 && var.random_suffix_length <= 16
    error_message = "Random suffix length must be between 0 and 16 characters."
  }
}

variable "use_random_suffix" {
  description = "Whether to use a random suffix for the resource name"
  type        = bool
  default     = true
}

variable "az_region_abbr_map" {
  type        = map(string)
  description = "Map of Azure region display names to their official short abbreviations for naming resources"
  default = {
    "East US"                      = "eus"
    "East US 2"                    = "eus2"
    "South Central US"             = "scus"
    "West US 2"                    = "wus2"
    "West US 3"                    = "wus3"
    "Australia East"               = "aue"
    "Southeast Asia"               = "sea"
    "North Europe"                 = "neu"
    "Sweden Central"               = "sw"
    "UK South"                     = "uks"
    "West Europe"                  = "weu"
    "Central US"                   = "cus"
    "North Central US"             = "ncus"
    "West US"                      = "wus"
    "South Africa North"           = "san"
    "Central India"                = "cin"
    "East Asia"                    = "ea"
    "Japan East"                   = "jpe"
    "Korea Central"                = "kr"
    "Canada Central"               = "ca"
    "France Central"               = "fr"
    "Germany West Central"         = "gw"
    "Italy North"                  = "itn"
    "Norway East"                  = "noe"
    "Poland Central"               = "pl"
    "Switzerland North"            = "szn"
    "UAE North"                    = "uaen"
    "Brazil South"                 = "brs"
    "Central US EUAP"              = "cuseuap"
    "East US 2 EUAP"               = "eus2euap"
    "Qatar Central"                = "qac"
    "Canada East"                  = "cae"
    "France South"                 = "frs"
    "Germany North"                = "gn"
    "Norway West"                  = "now"
    "Switzerland West"             = "szw"
    "UK West"                      = "ukw"
    "UAE Central"                  = "uae"
    "Brazil Southeast"             = "brse"
    "Japan West"                   = "jpw"
    "Australia Central"            = "au"
    "Australia Central 2"          = "auc2"
    "Australia Southeast"          = "ause"
    "Korea South"                  = "krs"
    "South India"                  = "sin"
    "West India"                   = "win"
    "South Africa West"            = "saw"
    "Sweden South"                 = "sds"
    "China East"                   = "cne"
    "China North"                  = "cnn"
    "China East 2"                 = "cne2"
    "China North 2"                = "cnn2"
    "China North 3"                = "cnn3"
    "USGov Arizona"                = "usga"
    "USGov Virginia"               = "usgv"
    "USGov Texas"                  = "usgt"
    "USDoD Central"                = "usdc"
    "USDoD East"                   = "usde"
    "US Gov Non-Regional"          = "usgnr"
    "Mexico Central"               = "mx"
    "Israel Central"               = "il"
    "Austria East"                 = "ate"
    "Malaysia South"               = "mys"
    "Taiwan North"                 = "twn"
    "Spain Central"                = "sp"
  }
}