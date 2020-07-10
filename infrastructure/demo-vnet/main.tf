# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "beershop-demo-vnet" {
  name     = "beershop-demovnet"
  location = "eastus2"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "beershop-demo-vnet" {
  name                = "vnet-beershop-demo"
  resource_group_name = azurerm_resource_group.beershop-demo-vnet.name
  location            = azurerm_resource_group.beershop-demo-vnet.location
  address_space       = ["10.0.0.0/16"]
}