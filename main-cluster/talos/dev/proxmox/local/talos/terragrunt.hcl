include "backend" {
  path = find_in_parent_folders("backend.hcl")
}

terraform {
  source = "/workspace/personal/infrastructure/terraform/modules/talos"
}

inputs = {
  cluster_name        = "talos"
  controller_endpoint = "10.0.0.10"
  controller_ips      = ["10.0.0.10"]
  worker_ips          = []
  # worker_ips          = ["10.0.1.11", "10.0.1.12", "10.0.1.13"]
  talos_version       = "1.11.1"
  kube_config_destination = "/workspace/kube-contexts/talos"
}

dependencies {
  paths = ["../vm"]
}