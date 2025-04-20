data "terraform_remote_state" "network_manager_state" {
  backend = "azurerm"
  config = {
    storage_account_name = var.network_manager_backend_config.storage_account_name
    container_name       = var.network_manager_backend_config.container_name
    key                  = var.network_manager_backend_config.key
    subscription_id      = var.network_manager_subscription_id
    resource_group_name  = var.network_manager_backend_config.resource_group_name
    use_azuread_auth = true
  }
}

module "spokes_deployment" {
  source = "../../NM_Modules/spokes_v2"

  for_each = {for k, v in var.spokes : v.name => v}

  providers = {
    azurerm = azurerm
    azurerm.network_manager = azurerm.network_manager
  }

  network_manager_id = data.terraform_remote_state.network_manager_state.outputs.network_manager_id
  region = each.value.region
  tags = var.tags
  resource_group_name = each.value.name
  vnets = each.value.vnets
  network_group_id = data.terraform_remote_state.network_manager_state.outputs.network_groups[each.value.region][each.value.environment]
  ipam_pool_id = data.terraform_remote_state.network_manager_state.outputs.spoke_ipam_pool_ids[each.value.region]
}


