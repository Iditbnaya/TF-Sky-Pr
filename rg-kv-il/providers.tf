provider "azurerm" {
  features {}
  subscription_id = var.management_subscription_id
}

provider "azurerm" {
  alias           = "management"
  features {}
  subscription_id = var.management_subscription_id
}

# provider "azurerm" {
#   features {}
#   subscription_id = var.default_subscription_id
# }