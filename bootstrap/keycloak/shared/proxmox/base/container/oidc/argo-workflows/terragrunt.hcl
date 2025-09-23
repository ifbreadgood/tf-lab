include "backend" {
  path   = find_in_parent_folders("backend.hcl")
  expose = true
}

terraform {
  source = "${include.backend.locals.modules_abs_dir}/keycloak/openid-client"
}

inputs = {
  realm_name          = "onprem"
  client_name         = "argo-workflows"
  client_id           = "argo-workflows"
  valid_redirect_uris = ["https://argo-workflows.trial.studio/oauth2/callback"]
}

dependencies {
  paths = ["../../realm"]
}