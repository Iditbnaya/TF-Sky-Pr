variable "name" {
  description = "The name of the resource group"
  type        = string
  
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
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