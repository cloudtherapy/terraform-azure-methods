terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.methods_client_id
  client_secret   = var.methods_client_secret
  tenant_id       = var.methods_tenant_id
  subscription_id = var.methods_subscription_id
}