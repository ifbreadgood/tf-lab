include "backend" {
  path = find_in_parent_folders("backend.hcl")
  expose = true
}

# terraform {
#   source = "${include.backend.locals.modules_abs_dir}/keycloak/realm"
# }