include "backend" {
  path   = find_in_parent_folders("backend.hcl")
  expose = true
}

terraform {
  source = "${include.backend.locals.modules_abs_dir}/keycloak/openid-client"
}

inputs = {
  realm_name                 = "onprem"
  client_name                = "argo-cd"
  client_id                  = "argo-cd"
  access_type                = "PUBLIC"
  pkce_code_challenge_method = "S256"
  valid_redirect_uris = [
    "https://argo-cd.trial.studio/auth/callback",
    "https://argo-cd.trial.studio/api/dex/callback",
  ]
}