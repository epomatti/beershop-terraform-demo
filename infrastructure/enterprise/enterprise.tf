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

resource "tfe_variable" "variables" {
  count        = length(tfe_workspace.workspaces)
  key          = "ARM_CLIENT_ID" 
  value        = var.ARM_CLIENT_ID
  category     = "terraform"
  workspace_id = tfe_workspace.workspaces[count.index].id
  sensitive    = true
}