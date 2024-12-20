terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "3.0.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-methods-terraform"
    storage_account_name = "methodsmpnterraform"
    container_name       = "methods-terraform-state"
    key                  = "azure-methods/infrastructure.tfstate"
    subscription_id      = "eef2d7b1-c33f-48ec-a949-5b87caad5c13"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "eef2d7b1-c33f-48ec-a949-5b87caad5c13"
}

provider "azuread" {
  features {}
}