resource "azurerm_resource_group" "rg-methods-shared" {
  name     = "rg-methods-shared"
  location = "East US"

  tags = {
    "cloudmethods:contact" = "cmoreira"
    "env:platform"         = "azure-methods"
    "env:provisioner"      = "Terraform"
  }
}

resource "azurerm_virtual_network" "methods-vnet-shared" {
  name                = "vnet-methods-shared"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name
  address_space       = ["10.157.0.0/20"]
  # dns_servers         = ["10.227.90.10", "10.227.90.20"]

  subnet {
    name           = "snet-methods-shared-private"
    address_prefixes = ["10.157.0.0/24"]
  }

  subnet {
    name           = "snet-methods-shared-public"
    address_prefixes = ["10.157.1.0/24"]
  }

  subnet {
    name           = "GatewaySubnet"
    address_prefixes = ["10.157.2.0/26"]
  }

  tags = {
    "cloudmethods:contact" = "cmoreira"
    "env:platform"         = "azure-methods"
    "env:provisioner"      = "Terraform"
  }
}

data "azurerm_subnet" "methods-gateway-subnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.methods-vnet-shared.name
  resource_group_name  = azurerm_resource_group.rg-methods-shared.name
}

resource "azurerm_local_network_gateway" "methods-tierpoint" {
  name                = "lgw-methods-tierpoint"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name
  gateway_address     = "66.203.72.213"
  address_space       = ["10.227.0.0/16"]
}

resource "azurerm_public_ip" "methods-public-ip" {
  name                = "pip-methods-public"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name
  allocation_method   = "Dynamic"
  sku = "Basic"
}
