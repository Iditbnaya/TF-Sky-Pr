variable "subscription_id" {
  type = string
  description = "The Azure subscription ID where spoke resources will be deployed"
  validation {
    condition     = can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", var.subscription_id))
    error_message = "The subscription_id must be a valid UUID in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

variable "tags" {
  type = map(string)
  description = "Tags to apply to all spoke resources"
  validation {
    condition     = alltrue([for k, v in var.tags : length(k) <= 512 && length(v) <= 256])
    error_message = "Tag keys must be <= 512 characters and values must be <= 256 characters."
  }
}

variable "network_manager_subscription_id" {
  type = string
  description = "The Azure subscription ID where Network Manager was deployed"
  validation {
    condition     = can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", var.network_manager_subscription_id))
    error_message = "The network_manager_subscription_id must be a valid UUID in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

variable "network_manager_backend_config" {
  type = object({
    storage_account_name = string
    container_name       = string
    key                  = string
    resource_group_name  = string
    subscription_id      = string
  })
  description = "Configuration for accessing the Network Manager's Terraform state in remote storage"
  
}

variable "spokes" {
  type = list(object({
    name   = string
    region = string
    environment = string
    vnets = list(
      object({
        name        = string,
        subnet_mask = number,
        subnets = list(object({
          name               = string,
          subnet_mask        = number
        }))
      })
    )
  }))
  description = "Configuration for spoke resources including VNets and subnets to be deployed and managed by Network Manager"
  validation {
    condition     = length(var.spokes) > 0
    error_message = "At least one spoke must be defined."
  }
  validation {
    condition     = alltrue([for spoke in var.spokes : can(regex("^[a-zA-Z0-9-_]{1,64}$", spoke.name))])
    error_message = "Spoke names must be 1-64 characters and can contain only letters, numbers, hyphens, and underscores."
  }
  validation {
    condition     = alltrue([for spoke in var.spokes : contains(["eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "southcentralus", "northcentralus", "westcentralus", "eastasia", "southeastasia", "japaneast", "japanwest", "australiaeast", "australiasoutheast", "australiacentral", "australiacentral2", "brazilsouth", "brazilsoutheast", "northeurope", "westeurope", "uksouth", "ukwest", "francecentral", "francesouth", "switzerlandnorth", "switzerlandwest", "germanynorth", "germanywestcentral", "norwayeast", "norwaywest", "canadacentral", "canadaeast", "southafricanorth", "southafricawest", "israelcentral", "indiawest", "indiacentral", "indiasouth", "jioindiacentral", "jioindiawest", "koreacentral", "koreasouth", "polandcentral", "uaenorth", "uaecentral", "swedencentral", "swedensouth", "qatarcentral", "mexicocentral", "malaysiawest", "italynorth", "chinaeast", "chinaeast2", "chinanorth", "chinanorth2", "germanywesto", "usdodeast", "usdodcentral", "usgovvirginia", "usgoviowa", "usgovarizona", "usgovtexas"], spoke.region)])
    error_message = "Spoke regions must be valid Azure regions."
  }
  validation {
    condition     = alltrue([for spoke in var.spokes : length(spoke.vnets) > 0])
    error_message = "Each spoke must have at least one VNet defined."
  }
  validation {
    condition     = alltrue([
      for spoke in var.spokes : alltrue([
        for vnet in spoke.vnets : 
          can(regex("^[a-zA-Z0-9-_]{1,64}$", vnet.name)) && 
          vnet.subnet_mask >= 16 && vnet.subnet_mask <= 29 &&
          length(vnet.subnets) > 0 && 
          alltrue([
            for subnet in vnet.subnets : 
              can(regex("^[a-zA-Z0-9-_]{1,80}$", subnet.name)) && 
              subnet.subnet_mask >= 16 && subnet.subnet_mask <= 29
          ])
      ])
    ])
    error_message = "VNet and subnet configurations must be valid. VNet names must be 1-64 characters, subnet names must be 1-80 characters, and subnet masks must be between 16 and 29."
  }
}
