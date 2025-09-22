terraform {
  required_version = "~> 1.13.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0.0"
    }
  }
}

provider "vault" {
  address = "https://vault.trial.studio"
}

variable "name" {
  type = string
}

resource "vault_kubernetes_auth_backend_role" "this" {
  bound_service_account_names      = ["vault-${var.name}", var.name]
  bound_service_account_namespaces = [var.name]
  role_name                        = var.name
  audience                         = "external-secrets-operator"
  token_ttl                        = 60 * 60 * 24
}