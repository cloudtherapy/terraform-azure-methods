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
    subnet_id                     = data.azurerm_subnet.methods-gateway-subnet.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection-tierpoint" {
  name                = "cn-shared-methods-tierpoint"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.methods-vnet-gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.methods-tierpoint.id

  shared_key = var.vpn_passphrase
}

#resource "azurerm_virtual_network_gateway_connection" "connection-flemington" {
#  name                = "cn-shared-methods-flemington"
#  location            = azurerm_resource_group.rg-methods-shared.location
#  resource_group_name = azurerm_resource_group.rg-methods-shared.name

#  type                       = "IPsec"
#  virtual_network_gateway_id = azurerm_virtual_network_gateway.methods-vnet-gateway.id
#  local_network_gateway_id   = azurerm_local_network_gateway.methods-flemington.id
#  shared_key                 = var.vpn_passphrase
#}

resource "azurerm_virtual_network_gateway_connection" "connection-norwood" {
  name                = "cn-shared-methods-norwood"
  location            = azurerm_resource_group.rg-methods-shared.location
  resource_group_name = azurerm_resource_group.rg-methods-shared.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.methods-vnet-gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.methods-norwood.id
  shared_key                 = var.vpn_passphrase
}
