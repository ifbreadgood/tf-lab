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

variable "data" {
  type = map(map(string))
}

data "vault_auth_backend" "this" {
  path = "kubernetes"
}

resource "vault_policy" "this" {
  name = var.name

  policy = <<-EOT
    path "${var.name}/data/*" {
      capabilities = ["read"]
    }
    path "${var.name}/metadata/*" {
      capabilities = ["list"]
    }
    EOT
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend = data.vault_auth_backend.this.path
  bound_service_account_names      = ["vault-${var.name}"]
  bound_service_account_namespaces = [var.name]
  role_name                        = var.name
  token_policies                   = [vault_policy.this.name]
  audience                         = "external-secrets-operator"
}

resource "vault_mount" "this" {
  path    = "/${var.name}"
  type    = "kv"
  options = { version = "2" }
}

resource "vault_kv_secret_backend_v2" "this" {
  mount        = vault_mount.this.path
  max_versions = 5
}

resource "vault_kv_secret_v2" "this" {
  for_each  = var.data
  data_json = jsonencode(each.value)
  mount     = vault_mount.this.path
  name      = each.key
}