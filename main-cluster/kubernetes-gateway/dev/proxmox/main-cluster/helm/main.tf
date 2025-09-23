terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
  }
}

provider "http" {}

provider "kubernetes" {
  host                   = var.kube_config.host
  cluster_ca_certificate = base64decode(var.kube_config.ca_certificate)
  client_certificate     = base64decode(var.kube_config.client_certificate)
  client_key             = base64decode(var.kube_config.client_key)
}

variable "kube_config" {
  type = object({
    ca_certificate     = string
    client_certificate = string
    client_key         = string
    host               = string
  })
}

data "http" "this" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"
}

resource "kubernetes_manifest" "this" {
  for_each = { for i in provider::kubernetes::manifest_decode_multi(data.http.this.response_body) : i.metadata.name => { for k, v in i : k => v if k != "status" } }
  manifest = each.value
}