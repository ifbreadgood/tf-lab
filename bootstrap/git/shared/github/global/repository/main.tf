terraform {
  required_version = "~> 1.12"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.6"
    }
  }
}

provider "github" {}

locals {
  repositories = {
    tf-modules = {}
    tf-lab = {}
    gh-workflow = {}
    ansible = {}
    kubernetes-base = {}
  }
}

module "repositories" {
  for_each = local.repositories
  source = "/workspace/personal/infrastructure/terraform/modules/github/repository"
  name = each.key
  visibility = "public"
}