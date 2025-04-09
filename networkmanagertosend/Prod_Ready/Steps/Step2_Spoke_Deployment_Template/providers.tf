terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
      version = "~> 2.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.25.0"
    }
  }
}

provider "azapi" {
  subscription_id = var.subscription_id
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "azurerm" {
  alias = "network_manager"
  subscription_id = var.network_manager_subscription_id
  features {}
}

provider "azapi" {
  alias = "network_manager"
  subscription_id = var.network_manager_subscription_id
}