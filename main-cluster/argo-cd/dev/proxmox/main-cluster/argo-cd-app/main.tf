terraform {
  required_version = "~> 1.13.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "kubernetes" {
  host                   = var.kube_config.host
  cluster_ca_certificate = base64decode(var.kube_config.ca_certificate)
  client_certificate     = base64decode(var.kube_config.client_certificate)
  client_key             = base64decode(var.kube_config.client_key)
}

provider "github" {}

variable "kube_config" {
  type = object({
    ca_certificate     = string
    client_certificate = string
    client_key         = string
    host               = string
  })
}

data "github_repository_file" "this" {
  file       = "manifests/argo-cd/app-argo-cd.yaml"
  repository = "kubernetes-base"
}

resource "kubernetes_manifest" "this" {
  manifest = yamldecode(data.github_repository_file.this.content)
}
