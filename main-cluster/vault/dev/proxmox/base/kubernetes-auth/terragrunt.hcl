include "backend" {
  path   = find_in_parent_folders("backend.hcl")
  expose = true
}

dependency "talos" {
  config_path = "${get_path_to_repo_root()}/main-cluster/talos/dev/proxmox/local/talos"
}

dependency "service_account_token" {
  config_path = "../../main-cluster/service-account"
}

inputs = {
  kubernetes_ca_cert = dependency.talos.outputs.kube_config.ca_certificate
  kubernetes_host    = dependency.talos.outputs.kube_config.host
  token_reviewer_jwt = dependency.service_account_token.outputs.token
}