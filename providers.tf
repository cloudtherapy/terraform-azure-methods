terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
    backend "remote" {
      hostname = "app.terraform.io"
      organization = "cloudtherapy"

      workspaces {
        name = "terraform-azure-methods"
      }
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