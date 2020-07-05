provider "azurerm" {
  features {
  }
}

# Variables

variable "TFC_WORKSPACE_NAME" {
  type = string
}

variable "ACR_ADMIN_PASSWORD" {
  type = string
}

locals {
  env  = merge(
    yamldecode(file("env/${var.TFC_WORKSPACE_NAME}.yaml"))
  )
}

# Resource Group

resource "azurerm_resource_group" "default" {
  name     = "beershop-${local.env.suffix}"
  location = local.env.rg_location
  tags     = local.env.tags
}


# Service Bus

resource "azurerm_servicebus_namespace" "default" {
  name                = "bus-beershop-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = local.env.servicebus_sku

  tags     = local.env.tags
}

resource "azurerm_servicebus_queue" "orders" {
  name                = local.env.servicebus_order_queuename
  resource_group_name = azurerm_resource_group.default.name
  namespace_name      = azurerm_servicebus_namespace.default.name
}

resource "azurerm_servicebus_queue_authorization_rule" "api" {
  name                = "api-permissions"
  namespace_name      = azurerm_servicebus_namespace.default.name
  queue_name          = local.env.servicebus_order_queuename
  resource_group_name = local.env.rg_name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "functions" {
  name                = "functions-permissions"
  namespace_name      = azurerm_servicebus_namespace.default.name
  queue_name          = local.env.servicebus_order_queuename
  resource_group_name = local.env.rg_name

  listen = true
  send   = false
  manage = false
}