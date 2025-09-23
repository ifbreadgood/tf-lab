include "backend" {
  path   = find_in_parent_folders("backend.hcl")
  expose = true
}

terraform {
  source = "${include.backend.locals.modules_abs_dir}/keycloak/accounts"
}

inputs = {
  realm_name = "onprem"
  groups = {
    "admin" = {
      members = ["admin"]
    }
    "devops" = {
      members = ["admin", "sre"]
    }
    "domain1" = {
      members = ["user1"]
    }
    "domain2" = {
      members = ["user2"]
    }
    "engineers" = {
      members = ["user1", "user2"]
    }
  }
  users = {
    admin = {
      first_name = "admin"
      last_name  = "admin"
      email      = "admin@admin.com"
    }
    sre = {
      first_name = "sre"
      last_name  = "sre"
      email      = "sre@sre.com"
    }
    user1 = {
      first_name = "user1"
      last_name  = "user1"
      email      = "user1@user1.com"
    }
    user2 = {
      first_name = "user2"
      last_name  = "user2"
      email      = "user2@user2.com"
    }
  }
}

dependencies {
  paths = ["../realm"]
}