output name {
  value = module.naming.standard_name
}

output id {
  value = azurerm_network_manager_ipam_pool.this.id
}

output "creation_time" {
  value = time_sleep.wait_for_ipam_pool.id
}
