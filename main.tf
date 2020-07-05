provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

# External Variables
variable "TFC_WORKSPACE_NAME" {
  type = string
}


# Local data
data "azurerm_client_config" "current" {}

# Configuration files
locals {
  tags = {
    Product = "BeerShop"
  }
  env = merge(
    yamldecode(file("env/${var.TFC_WORKSPACE_NAME}.yaml"))
  )
}

# Resource Group

resource "azurerm_resource_group" "maibeer" {
  name     = "maibeer-${local.env.suffix}"
  location = local.env.location
}

# STORAGE

resource "azurerm_storage_account" "default" {
  name                     = local.env.storage_name
  location                 = local.env.location
  resource_group_name      = local.env.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

# APP SERVICE PLAN (Linux)

resource "azurerm_app_service_plan" "linuxplan" {
  name                = "plan-mai-beer-${local.env.sufix}"
  location            = local.env.location
  resource_group_name = local.env.resource_group_name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
  tags = local.tags
}

# WEB APP FOR CONTAINERS (Frontend)

resource "azurerm_app_service" "frontend" {
  name                = "app-mai-beer-frontend-${local.env.sufix}"
  location            = local.env.location
  resource_group_name = local.env.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.linuxplan.id

  app_settings = {
    DOCKER_ENABLE_CI                    = true
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_URL          = "https://${azurerm_container_registry.acr.name}.azurecr.io"
    DOCKER_REGISTRY_SERVER_PASSWORD     = azurerm_container_registry.acr.admin_password
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.acr.admin_username
  }

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.name}.azurecr.io/maibeer-frontend:${local.env.sufix}"
    always_on        = "true"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

# FUNCTIONS (Backend)

resource "azurerm_application_insights" "maibeer" {
  name                = "appi-mainbeer-${local.env.sufix}"
  location            = local.env.location
  resource_group_name = local.env.resource_group_name
  application_type    = "other"

  tags = local.tags
}

resource "azurerm_function_app" "maibeer" {
  name                       = local.env.front_name
  location                   = local.env.location
  resource_group_name        = local.env.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.linuxplan.id
  storage_account_name       = azurerm_storage_account.default.name
  storage_account_access_key = azurerm_storage_account.default.primary_access_key
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"           = "python"
    "MAIBEER_COSMOSDB_CONNECTION_STRING" = azurerm_cosmosdb_account.default.connection_strings[0]
    "MAIBEER_KEYVAULT_URI"               = azurerm_key_vault.default.vault_uri
    "RATE_BEER_API_KEY" : var.RATE_BEER_API_KEY
    "RATE_BEER_API_URI" : var.RATE_BEER_API_URI
    "APPINSIGHTS_INSTRUMENTATIONKEY"  = azurerm_application_insights.maibeer.instrumentation_key
    "WEBSITE_RUN_FROM_PACKAGE"        = "ThisWillBeSetToAnURLByAzureDevOpsDeploy", // managed by Azure DevOps (must be not null)
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE" = "true"                                     // managed by Azure DevOps (must be not null)
  }

  site_config {
    # only for free plan
    #use_32_bit_worker_process = local.env.func_use_32_bit_worker_process
    cors {
      allowed_origins = ["https://${azurerm_app_service.frontend.default_site_hostname}"]
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"]
    ]
  }

  tags = local.tags
}