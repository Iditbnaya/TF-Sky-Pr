

resource "azurerm_resource_group" "kv_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a resource group for the Key Vault

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
}
 
