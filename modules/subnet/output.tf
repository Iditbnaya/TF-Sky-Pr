output "subnet_name" {
  description = "The name of the subnet"
  value       = module.subnet_name.standard_name
}

output "fw_private_ip" {
  description = "The IP address of the firewall"
  value       = (module.fw != null && length(module.fw) > 0) ? (length(module.fw[0].fw_private_ip) > 0 ? module.fw[0].fw_private_ip : null) : null
}

output "fw_name" {
  description = "The name of the firewall"
  value       = (module.fw != null && length(module.fw) > 0) ? (length(module.fw[0].fw_name) > 0 ? module.fw[0].fw_name : null) : null
}