include "backend" {
  path = find_in_parent_folders("backend.hcl")
}

dependencies {
  paths = ["${get_path_to_repo_root()}/main-cluster/vault/dev/proxmox/base/kubernetes-auth"]
}

inputs = {
  name = "cert-manager"
}