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

# ansible public key
resource "azurerm_ssh_public_key" "ansible" {
  name                = "ansible"
  resource_group_name = azurerm_resource_group.rg-methods-terraform.name
  location = "East US"
  public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTD8HrwW7d5xvgs0o0dXkyNFdgZwab4G9Ok2Irh7uuk0OOW/U9QyePpfHzDboSsyfSGjwG3qzn6zKncq1vg2YmaR2oOm555T5D3/faGdJ1UJbx5hqiogkfw4hXMreg/u9Ah9CuucDUKwRxQC/MhpVrGb1MAEuDd5ZKPT6QF99ssgno/ibrHdraENMsZu+FxmJZ/Ukmi6ik8eJYRlSvAEZXw2hQIEcEaYejWMnNmE06ys5xjQe30pmV2a/Wxg4NN2MrDFzCssSDARAMak5v0vGkLGTsJYx56NaKLqnOudkKnPkXK/AvvEB26L1F1kaZLyR0jrzjTuKKEuqUJReKf/MV"
}