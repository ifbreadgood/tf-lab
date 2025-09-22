include "backend" {
  path = find_in_parent_folders("backend.hcl")
  expose = true
}

terraform {
  source = "${include.backend.locals.modules_abs_dir}/keycloak/openid-client"
}

inputs = {
  realm_name = "onprem"
  client_name = "grafana"
  client_id = "grafana"
  valid_redirect_uris = ["https://grafana.trial.studio/login/generic_oauth"]
}

dependencies {
  paths = ["../../realm"]
}