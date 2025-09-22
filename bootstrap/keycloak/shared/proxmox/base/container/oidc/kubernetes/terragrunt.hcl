include "backend" {
  path = find_in_parent_folders("backend.hcl")
  expose = true
}

terraform {
  source = "${include.backend.locals.modules_abs_dir}/keycloak/openid-client"
}

inputs = {
  realm_name = "onprem"
  client_name = "kubernetes"
  client_id = "kubernetes"
  # kubectl oidc-login
  valid_redirect_uris = ["http://localhost:8000"]
}

dependencies {
  paths = ["../../realm"]
}