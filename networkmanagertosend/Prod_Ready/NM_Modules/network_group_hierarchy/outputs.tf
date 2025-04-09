output "network_group_ids" {
  value = {for idx, env in var.environments : env => azurerm_network_manager_network_group.network_group[env].id}
}