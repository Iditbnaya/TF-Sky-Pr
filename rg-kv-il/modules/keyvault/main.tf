data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  enable_rbac_authorization  = var.enable_rbac_authorization
  sku_name                    = var.sku
  public_network_access_enabled = var.public_network_access_enabled

#   network_acls {
#     bypass         = var.allow_bypass == "AzureServices" ? "AzureServices" : "None"
#     default_action = var.default_action
#   }

}

######create key vault private enpoint and private dns zone##########

# resource "azurerm_private_endpoint" "pe_kv" {
#   name                = format("pe-%s", var.name)
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_id

#   private_dns_zone_group {
#     name                 = "privatednszonegroup"
#     private_dns_zone_ids = [data.azurerm_private_dns_zone.main.id]
#   }

#   private_service_connection {
#     name                           = format("psc-%s", var.name)
#     private_connection_resource_id = azurerm_key_vault.this.id
#     is_manual_connection           = false
#     subresource_names              = ["Vault"]
#   }


# }

# data "azurerm_private_dns_zone" "main" {
#   name                = "privatelink.vaultcore.azure.net"
#   provider            = azurerm.connectivity
#   resource_group_name = var.dns_zone_rg
# }
