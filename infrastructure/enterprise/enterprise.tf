terraform {
  required_providers {
    tfe = "~> 0.19.0"
  }
}


locals {
  organization = "beershop"
  env = merge(
    yamldecode(file("enterprise.yaml"))
  )
}

resource "tfe_workspace" "beershop-shared" {
  count              = 1
  name               = local.workspaces[${count.index}]
  organization       = local.organization
  working_directory  = "infrastructure/enterprise"

  vcs_repo {
      identifier     = "epomatti/beershop-demo"
      oauth_token_id = var.OAUTH_TOKEN_ID
      branch         = local.branches[${count.index}]
  }

}