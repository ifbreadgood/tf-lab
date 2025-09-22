include "backend" {
  path   = find_in_parent_folders("backend.hcl")
}

dependency "talos" {
  config_path = "${get_path_to_repo_root()}/main-cluster/talos/dev/proxmox/local/talos"
}

inputs = {
  kube_config    = dependency.talos.outputs.kube_config
  repo_root_path = get_path_to_repo_root()
  name           = "external-secrets"
  repository     = "https://charts.external-secrets.io"
  chart_version  = "0.19.2"
}