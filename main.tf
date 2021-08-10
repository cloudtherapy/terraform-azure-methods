# * Terraform Configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-methods-terraform"
    storage_account_name = "methodsterraform"
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

resource "azurerm_resource_group" "rg-methods-terraform" {
  name     = "rg-methods-terraform"
  location = "East US"
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "methodsterraform"
  resource_group_name      = azurerm_resource_group.rg-.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

#module "msdn" {
#  source         = "./modules/msdn/"
#  vpn_passphrase = var.vpn_passphrase
#}

#resource "azurerm_management_group" "msdn_management_group" {
#  display_name = "MSDN Management Group"
#  name         = "mg-msdn"
#
#  subscription_ids = [
#    module.msdn.subscription_id
# ]
#}