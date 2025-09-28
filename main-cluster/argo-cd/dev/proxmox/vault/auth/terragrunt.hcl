include "backend" {
  path = find_in_parent_folders("backend.hcl")
}

dependency "keycloak" {
  config_path = "../../keycloak/oidc"
}

dependencies {
  paths = ["${get_path_to_repo_root()}/main-cluster/vault/dev/proxmox/base/kubernetes-auth"]
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