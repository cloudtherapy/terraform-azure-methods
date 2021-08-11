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

resource "azurerm_resource_group" "rg-methods-terraform" {
  name     = "rg-methods-terraform"
  location = "East US"
  
  tags = {
    "cloudmethods:contact"  = "cmoreira"
    "env:platform"    = "azure-methods"
    "env:provisioner" = "Terraform"
  }
}

resource "azurerm_storage_account" "methods-storage-account" {
  name                     = "methodsmpnterraform"
  resource_group_name      = azurerm_resource_group.rg-methods-terraform.name
  location                 = azurerm_resource_group.rg-methods-terraform.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "env:prod"
  }
}

resource "azurerm_storage_container" "methods-storage-container" {
  name                  = "methods-terraform-state"
  storage_account_name  = azurerm_storage_account.methods-storage-account.name
  container_access_type = "private"
}