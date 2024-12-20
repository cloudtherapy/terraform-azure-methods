resource "azurerm_resource_group" "rg-methods-terraform" {
  name     = "rg-methods-terraform"
  location = "East US"

  tags = {
    "cloudmethods:contact" = "cmoreira"
    "env:platform"         = "azure-methods"
    "env:provisioner"      = "Terraform"
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
  storage_account_id  = azurerm_storage_account.methods-storage-account.id
  container_access_type = "private"
}