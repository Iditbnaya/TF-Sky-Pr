module "naming" {
  source = "../naming"
  resource_type = "network_manager"
  name = var.name
  region = var.region
}

resource "azurerm_network_manager" "this" {
  name = module.naming.standard_name
  location = var.region
  tags = var.tags

  resource_group_name = var.resource_group_name
  
  scope {
    management_group_ids  = formatlist("/providers/Microsoft.Management/managementGroups/%s", var.management_groups)
    subscription_ids  = formatlist("/subscriptions/%s", var.subscriptions)
  }
  
  scope_accesses = var.scope_accesses

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "time_sleep" "wait_for_network_manager" {
  depends_on = [azurerm_network_manager.this]
  create_duration = "10s"
}
