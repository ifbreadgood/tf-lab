include "backend" {
  path = find_in_parent_folders("backend.hcl")
}

terraform {
  source = "/workspace/personal/infrastructure/terraform/modules/proxmox/vm"
}

inputs = {
  name        = "main"
  node_name   = "pve"
  cpu         = 10
  memory      = 40960
  iso         = "talos-1.11.1.iso"
  volume_size = 200
  ip = {
    address = "dhcp"
  }
  mac_address = "AA:AA:AA:AA:AA:AA"
}