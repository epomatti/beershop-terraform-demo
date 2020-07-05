terraform {
  required_providers {
    tfe = "~> 0.19.0"
  }
}

variable "OAUTH_TOKEN_ID" {
  type = string
}

locals {
  organization = "beershop"
  env = merge(
    yamldecode(file("enterprise.yaml"))
  )
}

resource "tfe_workspace" "beershop-shared" {
  count              = 1
  name               = local.env.workspaces[count.index]
  organization       = local.organization
  working_directory  = "infrastructure/shared"

  vcs_repo {
      identifier     = "epomatti/beershop-demo"
      oauth_token_id = var.OAUTH_TOKEN_ID
      branch         = local.env.branches[count.index]
  }

}