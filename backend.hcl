locals {
  path = regex("(?P<project>[^/]+)/(?P<application>[^/]+)/(?P<environment>[^/]+)/(?P<platform>[^/]+)/(?P<location>[^/]+)/(?P<resource>[^/]+).*", path_relative_to_include())
  project = local.path.project
  application = local.path.application
  environment = local.path.environment
  platform = local.path.platform
  location = local.path.location
  resource = local.path.resource
  default_tags = {
    project = local.project
    application = local.application
    environment = local.environment
    platform = local.platform
    location = local.location
    resource = local.resource
  }
  repo_abs_dir = "/workspace/personal/infrastructure/terraform/lab"
}

generate "backend" {
  path      = "_backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      backend "local" {
        path = "${local.repo_abs_dir}/${path_relative_to_include()}/terraform.tfstate"
      }
    }
    EOF
}