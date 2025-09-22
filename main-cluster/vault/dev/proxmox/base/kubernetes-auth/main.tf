terraform {
  required_version = "~> 1.13.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.0.0"
    }
  }
}

provider "vault" {
  address = "https://vault.trial.studio"
}

variable "kubernetes_ca_cert" {
  type = string
}

variable "kubernetes_host" {
  type = string
}

variable "token_reviewer_jwt" {
  type = string
}

resource "vault_auth_backend" "this" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend            = vault_auth_backend.this.path
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = base64decode(var.kubernetes_ca_cert)
  token_reviewer_jwt = var.token_reviewer_jwt
}