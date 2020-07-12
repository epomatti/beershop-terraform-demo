provider "azurerm" {
  features {
  }
}

# Terraform Variables

variable "TFC_WORKSPACE_NAME" {
  type = string
}

variable "PSQL_PASSWORD" {
  type = string
}

variable "ACR_ADMIN_PASSWORD" {
  type = string
}

# Environment Parameters

locals {
  env = merge(
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

# VNet

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-beershop-${local.env.suffix}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  tags = local.env.tags
}

resource "azurerm_subnet" "internal" {
  name                 = "snet-beershop-${local.env.suffix}"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

# Postgres

resource "azurerm_postgresql_server" "default" {
  name                = "psql-beershop-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  administrator_login          = "beershop"
  administrator_login_password = var.PSQL_PASSWORD

  sku_name   = local.env.psql_sku_name
  version    = 11
  storage_mb = local.env.psql_storage_mb

  backup_retention_days        = local.env.psql_backup_retention_days
  geo_redundant_backup_enabled = local.env.psql_geo_redundant_backup_enabled
  auto_grow_enabled            = local.env.psql_autogrow_enabled

  public_network_access_enabled    = local.env.psql_public_network_access_enabled
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = local.env.tags
}

resource "azurerm_postgresql_virtual_network_rule" "default" {
  name                                 = "postgresql-vnet-rule"
  resource_group_name                  = azurerm_resource_group.default.name
  server_name                          = azurerm_postgresql_server.default.name
  subnet_id                            = azurerm_subnet.internal.id
  ignore_missing_vnet_service_endpoint = true
}

resource "azurerm_postgresql_firewall_rule" "default" {
  name                = "psql-firewall"
  resource_group_name = azurerm_resource_group.default.name
  server_name         = azurerm_postgresql_server.default.name

  # Allows Azure endpoints
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
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

# App Service Plans

resource "azurerm_app_service_plan" "default" {
  name                = "plan-beershop-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier = local.env.plan_tier
    size = local.env.plan_sku
  }

  tags = local.env.tags
}

# Web Apps

resource "azurerm_app_service" "app" {
  name                = "app-beershop-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  app_service_plan_id = azurerm_app_service_plan.default.id

  app_settings = {
    DOCKER_ENABLE_CI                                = true
    WEBSITES_ENABLE_APP_SERVICE_STORAGE             = false
    DOCKER_REGISTRY_SERVER_URL                      = "https://beershop.azurecr.io"
    DOCKER_REGISTRY_SERVER_USERNAME                 = "beershop"
    DOCKER_REGISTRY_SERVER_PASSWORD                 = var.ACR_ADMIN_PASSWORD
    BEERSHOP_SERVICEBUS_PRIMARY_CONNECTION_STRING   = azurerm_servicebus_namespace.default.default_primary_connection_string
    BEERSHOP_SERVICEBUS_SECONDARY_CONNECTION_STRING = azurerm_servicebus_namespace.default.default_secondary_connection_string
    BEERSHOP_SERVICEBUS_CONNECTION_STRING           = local.env.app_servicebus_connection_string
    PGUSER                                          = "beershop@${azurerm_postgresql_server.default.name}"
    PGHOST                                          = "${azurerm_postgresql_server.default.name}.postgres.database.azure.com"
    PGPASSWORD                                      = var.PSQL_PASSWORD
    PGDATABASE                                      = "beershop"
    PGPORT                                          = 5432
  }

  site_config {
   linux_fx_version = "DOCKER|beershop.azurecr.io/beershop-app:latest"
   always_on        = local.env.app_alwayson
  }

  tags = local.env.tags
}

# Application Insights

resource "azurerm_application_insights" "functions" {
  name                = "appi-beershop-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  application_type    = "other"

  tags = local.env.tags
}

# Functions

resource "azurerm_function_app" "beershop" {
  name                       = "func-beershop-${local.env.suffix}"
  resource_group_name        = azurerm_resource_group.default.name
  location                   = azurerm_resource_group.default.location
  app_service_plan_id        = azurerm_app_service_plan.default.id
  storage_account_name       = azurerm_storage_account.default.name
  storage_account_access_key = azurerm_storage_account.default.primary_access_key
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    DOCKER_ENABLE_CI                    = true
    APPINSIGHTS_INSTRUMENTATIONKEY      = azurerm_application_insights.functions.instrumentation_key
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_URL          = "https://beershop.azurecr.io"
    DOCKER_REGISTRY_SERVER_USERNAME     = "beershop"
    DOCKER_REGISTRY_SERVER_PASSWORD     = var.ACR_ADMIN_PASSWORD
    AzureWebJobsServiceBus              = azurerm_servicebus_namespace.default.default_primary_connection_string
    PGUSER                              = "beershop@${azurerm_postgresql_server.default.name}"
    PGHOST                              = "${azurerm_postgresql_server.default.name}.postgres.database.azure.com"
    PGPASSWORD                          = var.PSQL_PASSWORD
    PGDATABASE                          = "beershop"
    PGPORT                              = 5432
  }

  site_config {
    linux_fx_version = "DOCKER|beershop.azurecr.io/beershop-functions:latest"
  }

  tags = local.env.tags
}

# Log Analytics

resource "azurerm_log_analytics_workspace" "app" {
  name                = "log-beershop-webapp-${local.env.suffix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.env.tags
}