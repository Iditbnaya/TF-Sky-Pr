resource "azurerm_resource_group" "kv_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a resource group for the Key Vault

resource "time_sleep" "wait_for_rg" {
  depends_on = [azurerm_resource_group.kv_rg]
  create_duration = "30s"
}

module "keyvault" {
  source              = "../../../modules/keyvault"
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  soft_delete_retention_days   = var.soft_delete_retention_days
  purge_protection_enabled     = var.purge_protection_enabled
  enable_rbac_authorization    = var.enable_rbac_authorization
  sku                          = var.sku
  public_network_access_enabled = var.public_network_access_enabled
  enabled_for_deployment = var.enabled_for_deployment
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  bypass = var.allow_bypass
  default_action = var.default_action
  allowed_ip_addresses = var.allowed_ip_addresses

  depends_on = [time_sleep.wait_for_rg]
}


