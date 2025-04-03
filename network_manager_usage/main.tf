# Create a resource group, VNet and subnets for the existing hub
# Uncomment this to use the remote state


#data "terraform_remote_state" "network_manager_deployment_existing_hub" {
#  backend = "azurerm"
#  config = {
#    resource_group_name = "network-manager-rg"
#    storage_account_name = "networkmanagerstorage"
#    container_name = "network-manager-container"
#    key = "network_manager_deployment_existing_hub.tfstate"
#  }
#}

# Uncomment this to use the local state
data "terraform_remote_state" "local_existing_hub_deployment" {
  backend = "local"
  config = {
    path = "../network_manager_deployment_existing_hub/terraform.tfstate"
  }
}

# Create the Spokes Resources
module "multi_region_spokes" {
  source = "../modules/multi_region_spokes"

  for_each = tomap({ for k,v in var.spoke : v.region => v })

  network_manager_id = data.terraform_remote_state.local_existing_hub_deployment.outputs.network_manager_id
  ipam_pool_id = data.terraform_remote_state.local_existing_hub_deployment.outputs.ipam_pools[each.value.region].spoke_pool_ids
  spoke = each.value.spokes
  tags = var.tags
  region = each.value.region
  hub_id = data.terraform_remote_state.local_existing_hub_deployment.outputs.hub_vnet_ids[each.value.region]
  fw_private_ip = data.terraform_remote_state.local_existing_hub_deployment.outputs.fw_private_ip[each.value.region]

  depends_on = [data.terraform_remote_state.local_existing_hub_deployment]
}