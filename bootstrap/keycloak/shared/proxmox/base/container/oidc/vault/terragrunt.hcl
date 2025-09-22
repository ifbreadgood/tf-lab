include "backend" {
  path = find_in_parent_folders("backend.hcl")
  expose = true
}

terraform {
  source = "${include.backend.locals.modules_abs_dir}/keycloak/openid-client"
}

inputs = {
  realm_name = "onprem"
  client_name = "vault"
  client_id = "vault"
  valid_redirect_uris = ["https://vault.trial.studio/ui/vault/auth/oidc/oidc/callback"]
}

dependencies {
  paths = ["../../realm"]
}