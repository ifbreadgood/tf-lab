include "backend" {
  path = find_in_parent_folders("backend.hcl")
}

dependency "keycloak" {
  config_path = "../../keycloak/oidc"
}

inputs = {
  name = "argo-cd"
  data = {
    oidc = {
      issuer    = "https://keycloak.trial.studio/realms/${dependency.keycloak.outputs.realm}"
      client-id = dependency.keycloak.outputs.client_id
    }
  }
}