terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.1"
    }
  }
}

provider "azurerm" {
  features {
  }
}

locals {
  location = "eastus2"
  tags = {
    environment = "shared"
    product     = "beershop"
  }
}

resource "azurerm_resource_group" "default" {
  name     = "beershop-shared"
  location = local.location
  tags     = local.tags
}


resource "azurerm_container_registry" "default" {
  name                = "beershop"
  resource_group_name = azurerm_resource_group.default.name
  location            = local.location
  sku                 = "Basic"
  admin_enabled       = true
  tags = {
    environment = "shared"
    product     = "beershop"
  }
}

output "acr_admin_password" {
  value     = azurerm_container_registry.default.admin_password
  sensitive = true
}
