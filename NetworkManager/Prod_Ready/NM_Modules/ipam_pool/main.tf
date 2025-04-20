module "naming" {
  source = "../naming"
  resource_type = "ipam_pool"
  name = var.name
  region = var.region
}

resource "azurerm_network_manager_ipam_pool" "this" {

  name               = module.naming.standard_name
  location           = var.region
  network_manager_id = var.network_manager_id
  display_name       = var.name
  address_prefixes   = var.address_prefixes

  parent_pool_name = var.is_child_pool ? var.parent_pool_name : null 

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "time_sleep" "wait_for_ipam_pool" {
  depends_on = [azurerm_network_manager_ipam_pool.this]

  create_duration = "30s"
}
