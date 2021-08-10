resource "azurerm_resource_group" "rg-methods-shared" {
  name     = "rg-methods-shared"
  location = "East US"
}

resource "azurerm_virtual_network" "methods-vnet-shared" {
  name                = "vnet-methods-shared"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name
  address_space       = ["10.130.0.0/20"]
  #dns_servers         = ["10.227.90.10", "10.227.90.20"]

  subnet {
    name           = "snet-methods-shared-private"
    address_prefix = "10.130.0.0/24"
  }

  subnet {
    name           = "snet-methods-shared-public"
    address_prefix = "10.130.1.0/24"
  }

  tags = {
    environment = "env:prod"
  }
}

resource "azurerm_subnet" "methods-gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg-methods-shared.name
  virtual_network_name = azurerm_virtual_network.methods-vnet-shared.name
  address_prefixes     = ["10.130.2.0/26"]
}

resource "azurerm_local_network_gateway" "methods-tierpoint" {
  name                = "lgw-methods-tierpoint"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name
  gateway_address     = "66.203.72.213"
  address_space       = ["10.227.0.0/16"]
}

resource "azurerm_local_network_gateway" "methods-flemington" {
  name                = "lgw-methods-flemington"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name
  gateway_address     = "23.31.233.13"
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_public_ip" "methods-public-ip" {
  name                = "pip-methods-public"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "methods-vnet-gateway" {
  name                = "vgw-methods-shared"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.methods-public-ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.methods-gateway-subnet.id
  }
}