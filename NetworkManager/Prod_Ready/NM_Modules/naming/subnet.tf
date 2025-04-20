# Specialized function for subnet naming 
# with format: snet-<sanitized-subnet-name>-<sanitized-region>
output "subnet_name" {
  description = "Generates a subnet name for a given subnet key with sanitized inputs"
  value       = "snet-${replace(lower(coalesce(var.subnet_name, var.name)), local.allowed_chars_regex["default"], "")}-${replace(lower(var.region), local.allowed_chars_regex["default"], "")}"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = ""
} 