terraform {
  required_providers {
    adguard = {
      source  = "gmichels/adguard"
      version = "1.6.2"
    }
  }
}

provider "adguard" {
  # host     = "10.0.0.5"
  # scheme   = "http"
  host     = "adguard.trial.studio"
  scheme   = "https"
  username = "adguard"
  password = "adguard1"
}

locals {
  domains = {
    "proxmox.trial.studio"          = "10.0.0.4"
    "base.trial.studio"             = "10.0.0.5"
    "asterisk.trial.studio"         = "10.0.0.55"
    "adguard.trial.studio"          = "10.0.0.5"

    "haproxy.trial.studio"          = "10.0.0.5"
    "keycloak.trial.studio"         = "10.0.0.5"
    "keycloak-db.trial.studio"      = "10.0.0.5"
    "vault.trial.studio"            = "10.0.0.5"
    "grafana.trial.studio"          = "10.0.0.5"
    "victoria-metrics.trial.studio" = "10.0.0.5"
    "victoria-logs.trial.studio"    = "10.0.0.5"

    "vault-direct.trial.studio"     = "10.0.0.104"

    "argo-cd.trial.studio"          = "10.0.0.128"
    "argo-workflows.trial.studio"   = "10.0.0.128"
    "argo-events.trial.studio"      = "10.0.0.128"
  }
}

resource "adguard_rewrite" "test" {
  for_each = local.domains
  domain   = each.key
  answer   = each.value
}