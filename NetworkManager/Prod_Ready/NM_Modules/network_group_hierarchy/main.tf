module "ng_name" {
    source = "../naming"

    for_each = {for idx, env in var.environments : env => {
    name = env
    environment = env
    index = idx
  }}

    name = "${var.name}-${each.value.environment}"
    region = var.regions
    resource_type = "network_group"
}

resource "azurerm_network_manager_network_group" "network_group" {
    for_each = {for idx, env in var.environments : env => {
    name = env
    environment = env
    index = idx
  }}

  name = module.ng_name[each.key].standard_name
  network_manager_id = var.network_manager_id
  depends_on = [module.ng_name]
}

