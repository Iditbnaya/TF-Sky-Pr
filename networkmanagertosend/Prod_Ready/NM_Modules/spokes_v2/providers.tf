terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.0.0"
      configuration_aliases = [azurerm, azurerm.network_manager]
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.3.0"
    }
  }
}
