terraform {
  required_providers {
    tfe = "~> 0.19.0"
  }
}

variable "OAUTH_TOKEN_ID" {
  type = string
}

variable "ARM_CLIENT_ID" {
  type = string
}

locals {
  organization = "beershop"
  env = merge(
    yamldecode(file("enterprise.yaml"))
  )
}


# Workspaces

resource "tfe_workspace" "workspaces" {
  count              = length(local.env.workspaces)
  name               = local.env.workspaces[count.index]
  organization       = local.organization
  working_directory  = "infrastructure/shared"

  vcs_repo {
      identifier     = "epomatti/beershop-terraform-demo"
      oauth_token_id = var.OAUTH_TOKEN_ID
      branch         = local.env.branches[count.index]
  }

}

# Azure ARM Provider

resource "tfe_variable" "ARM_CLIENT_ID" {
  count        = length(tfe_workspace.workspaces)
  key          = "ARM_CLIENT_ID" 
  value        = var.ARM_CLIENT_ID
  category     = "environment"
  workspace_id = tfe_workspace.workspaces[count.index].id
  sensitive    = false
}

resource "tfe_variable" "ARM_CLIENT_SECRET" {
  count        = length(tfe_workspace.workspaces)
  key          = "ARM_CLIENT_SECRET" 
  value        = var.ARM_CLIENT_SECRET
  category     = "environment"
  workspace_id = tfe_workspace.workspaces[count.index].id
  sensitive    = true
}

resource "tfe_variable" "ARM_SUBSCRIPTION_ID" {
  count        = length(tfe_workspace.workspaces)
  key          = "ARM_SUBSCRIPTION_ID" 
  value        = var.ARM_SUBSCRIPTION_ID
  category     = "environment"
  workspace_id = tfe_workspace.workspaces[count.index].id
  sensitive    = false
}

resource "tfe_variable" "ARM_TENANT_ID" {
  count        = length(tfe_workspace.workspaces)
  key          = "ARM_TENANT_ID" 
  value        = var.ARM_TENANT_ID
  category     = "environment"
  workspace_id = tfe_workspace.workspaces[count.index].id
  sensitive    = false
}