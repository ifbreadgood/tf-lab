include "backend" {
  path = find_in_parent_folders("backend.hcl")
}

dependency "talos" {
  config_path = "${get_path_to_repo_root()}/main-cluster/talos/dev/proxmox/local/talos"
}

inputs = {
  kube_config = dependency.talos.outputs.kube_config
}