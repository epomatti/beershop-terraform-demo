provider "azurerm" {
  features {
  }
}

# Variables

variable "TFC_WORKSPACE_NAME" {
  type = string
}

variable "SQLSERVER_ADMIN_PASSWORD" {
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

# Storage Account

resource "azurerm_storage_account" "default" {
  name                     = "stbeershop${local.env.suffix}"
  resource_group_name      = azurerm_resource_group.default.name
  location                 = azurerm_resource_group.default.location
  account_tier             = "Standard"
  account_replication_type = local.env.st_replication

  tags = local.env.tags
}


# SQL Server

resource "azurerm_sql_server" "default" {
  name                         = "sql-beershop-${local.env.suffix}"
  resource_group_name          = azurerm_resource_group.default.name
  location                     = azurerm_resource_group.default.location
  version                      = "12.0"
  administrator_login          = "beershop"
  administrator_login_password = var.SQLSERVER_ADMIN_PASSWORD

  lifecycle {
    prevent_destroy = true
  }

  tags = local.env.tags
}

resource "azurerm_sql_database" "default" {
  name                = "sqldb-beershop-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  server_name         = azurerm_sql_server.default.name
  edition             = local.env.sqldb_edition

  lifecycle {
    prevent_destroy = true
  }

  tags = local.env.tags
}


# Service Bus

resource "azurerm_servicebus_namespace" "default" {
  name                = "bus-beershop-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = local.env.bus_sku

  tags = local.env.tags
}

resource "azurerm_servicebus_queue" "orders" {
  name                = "sbq-orders"
  resource_group_name = azurerm_resource_group.default.name
  namespace_name      = azurerm_servicebus_namespace.default.name
}

resource "azurerm_servicebus_queue_authorization_rule" "api" {
  name                = "api-permissions"
  namespace_name      = azurerm_servicebus_namespace.default.name
  queue_name          = "sbq-orders"
  resource_group_name = azurerm_resource_group.default.name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "functions" {
  name                = "functions-permissions"
  namespace_name      = azurerm_servicebus_namespace.default.name
  queue_name          = "sbq-orders"
  resource_group_name = azurerm_resource_group.default.name

  listen = true
  send   = false
  manage = false
}


# App Service Plans

resource "azurerm_app_service_plan" "api" {
  name                = "plan-beershop-api-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier = local.env.plan_api_tier
    size = local.env.plan_api_sku
  }

  tags = local.env.tags
}

resource "azurerm_app_service_plan" "functions" {
  name                = "plan-beershop-functions-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier = local.env.plan_api_tier
    size = local.env.plan_api_sku
  }

  tags = local.env.tags
}

# Web Apps

resource "azurerm_app_service" "api" {
  name                = "app-beershop-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  app_service_plan_id = azurerm_app_service_plan.api.id

  app_settings = {
    DOCKER_ENABLE_CI                                = true
    WEBSITES_ENABLE_APP_SERVICE_STORAGE             = false
    DOCKER_REGISTRY_SERVER_URL                      = "https://beershop.azurecr.io"
    DOCKER_REGISTRY_SERVER_USERNAME                 = "beershop"
    DOCKER_REGISTRY_SERVER_PASSWORD                 = var.ACR_ADMIN_PASSWORD
    # beershop variables
    BEERSHOP_SQLSERVER_PASSWORD                     = var.SQLSERVER_ADMIN_PASSWORD
    BEERSHOP_SERVICEBUS_PRIMARY_CONNECTION_STRING   = azurerm_servicebus_queue_authorization_rule.api.primary_connection_string
    BEERSHOP_SERVICEBUS_SECONDARY_CONNECTION_STRING = azurerm_servicebus_queue_authorization_rule.api.secondary_connection_string
    BEERSHOP_SERVICEBUS_CONNECTION_STRING           = local.env.app_api_servicebus_connection_string
  }

  site_config {
    linux_fx_version = "DOCKER|beershop.azurecr.io/beershop-api:${local.env.suffix}"
    always_on        = local.env.app_api_alwayson
  }

  tags = local.env.tags
}

# Application Insights

resource "azurerm_application_insights" "functions" {
  name                = "appi-beershop-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  application_type    = "other"

  tags = local.tags
}


# Functions

resource "azurerm_function_app" "beershop" {
  name                       = "func-beershop-${local.env.suffix}"
  resource_group_name        = azurerm_resource_group.default.name
  location                   = azurerm_resource_group.default.location
  app_service_plan_id        = azurerm_app_service_plan.functions.id
  storage_account_name       = azurerm_storage_account.default.name
  storage_account_access_key = azurerm_storage_account.default.primary_access_key
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"      = azurerm_application_insights.functions.instrumentation_key
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
    "DOCKER_REGISTRY_SERVER_URL"          = "https://beershop.azurecr.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = "beershop"
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = var.ACR_ADMIN_PASSWORD
    #"WEBSITE_RUN_FROM_PACKAGE"            = "ThisWillBeSetToAnURLByAzureDevOpsDeploy", // managed by Azure DevOps (must be not null)
    #"WEBSITE_ENABLE_SYNC_UPDATE_SITE"     = "true"                                     // managed by Azure DevOps (must be not null)
    # beershop variables
    BEERSHOP_SQLSERVER_PASSWORD           = var.SQLSERVER_ADMIN_PASSWORD
    AzureWebJobsServiceBus                = azurerm_servicebus_queue_authorization_rule.api.primary_connection_string
  }

  site_config {
    linux_fx_version = "DOCKER|beershop.azurecr.io/beershop-functions:${local.env.suffix}"
    always_on        = local.env.functions_alwayson
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"]
    ]
  }

  tags = local.tags
}