terraform {
  required_version = "~> 1.13.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
  }
}

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

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "vault"
  }
}

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace_v1.this.metadata.0.name
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  metadata {
    name = "vault-auth-delegator"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.this.metadata.0.name
    namespace = kubernetes_namespace_v1.this.metadata.0.name
  }
}

resource "kubernetes_token_request_v1" "this" {
  metadata {
    name      = kubernetes_service_account_v1.this.metadata.0.name
    namespace = kubernetes_namespace_v1.this.metadata.0.name
  }
  spec {
    expiration_seconds = 60 * 60 * 24 * 365
  }
}

output "token" {
  value     = kubernetes_token_request_v1.this.token
  sensitive = true
}