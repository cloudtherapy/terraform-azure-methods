# Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "rg-shared-services"
}

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "cloudmethods"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}

# ansible public key
resource "azurerm_ssh_public_key" "ansible" {
  name                = "ansible"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resource_group_location
  public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTD8HrwW7d5xvgs0o0dXkyNFdgZwab4G9Ok2Irh7uuk0OOW/U9QyePpfHzDboSsyfSGjwG3qzn6zKncq1vg2YmaR2oOm555T5D3/faGdJ1UJbx5hqiogkfw4hXMreg/u9Ah9CuucDUKwRxQC/MhpVrGb1MAEuDd5ZKPT6QF99ssgno/ibrHdraENMsZu+FxmJZ/Ukmi6ik8eJYRlSvAEZXw2hQIEcEaYejWMnNmE06ys5xjQe30pmV2a/Wxg4NN2MrDFzCssSDARAMak5v0vGkLGTsJYx56NaKLqnOudkKnPkXK/AvvEB26L1F1kaZLyR0jrzjTuKKEuqUJReKf/MV"
}

# Network Security Group
resource "azurerm_network_security_group" "methods_nsg" {
  name                = "nsg-methods"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Virtual Network
resource "azurerm_virtual_network" "methods_network" {
  name                = "vnet-shared-10-157-0"
  address_space       = ["10.157.0.0/20"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet 1
resource "azurerm_subnet" "methods_subnet_1" {
  name                 = "snet-shared-10-157-0-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.methods_network.name
  address_prefixes     = ["10.157.0.0/24"]
}

# Subnet 1 NSG Association
resource "azurerm_subnet_network_security_group_association" "methods_nsg_subnet1" {
  subnet_id                 = azurerm_subnet.methods_subnet_1.id
  network_security_group_id = azurerm_network_security_group.methods_nsg.id
}

# Subnet 2
resource "azurerm_subnet" "methods_subnet_2" {
  name                 = "snet-shared-10-157-1-0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.methods_network.name
  address_prefixes     = ["10.157.1.0/24"]
}

# Subnet 2 NSG Association
resource "azurerm_subnet_network_security_group_association" "methods_nsg_subnet2" {
  subnet_id                 = azurerm_subnet.methods_subnet_2.id
  network_security_group_id = azurerm_network_security_group.methods_nsg.id
}

# Gateway Subnet
resource "azurerm_subnet" "vnet_shared_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.methods_network.name
  address_prefixes     = ["10.157.2.0/27"]
}

resource "azurerm_local_network_gateway" "tierpoint" {
  name                = "lgw-shared-services-tierpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = "66.203.72.213"
  address_space       = ["10.227.0.0/16"]
}

resource "azurerm_public_ip" "vnet_shared_gateway_ip" {
  name                = "pip-shared-services-vgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_virtual_network_gateway" "vnet_shared_gateway" {
  name                = "vgw-shared-services"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.vnet_shared_gateway_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_shared_gateway_subnet.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection_tierpoint" {
  name                = "cn-shared-services-tierpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_shared_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.tierpoint.id

  shared_key = var.vpn_passphrase
}