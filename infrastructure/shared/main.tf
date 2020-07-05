provider "azurerm" {
  features {
  }
}

resource "azurerm_container_registry" "default" {

  name                = "beershop"
  resource_group_name = "beershop"
  location            = "brazilsouth"
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    environment       = "shared"
    product           = "beershop"
  }

}

output "acr_admin_password" {
  value = azurerm_container_registry.default.admin_password
}