terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.1.0"
    }
  }
}

provider "vault" {}

locals {
  # vault_url = "http://vault-global-active.vault-global:8200"
  vault_url           = "https://vault.trial.studio"
  seconds_1_month     = 60 * 60 * 24 * 30
  cert_algorithm      = "ec"
  cert_algorithm_bits = 256
  base_domain         = "trial.studio"
}

# --------- certificate authority

resource "vault_mount" "root" {
  path                      = "pki"
  type                      = "pki"
  default_lease_ttl_seconds = local.seconds_1_month * 3
  max_lease_ttl_seconds     = local.seconds_1_month * 12
}

resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on           = [vault_mount.root]
  backend              = vault_mount.root.path
  type                 = "internal"
  common_name          = "trialstudio"
  issuer_name          = "vault"
  ttl                  = local.seconds_1_month * 3
  key_type             = local.cert_algorithm
  key_bits             = local.cert_algorithm_bits
  exclude_cn_from_sans = true
  alt_names            = [local.base_domain]
}

resource "vault_pki_secret_backend_config_urls" "root" {
  backend                 = vault_mount.root.path
  issuing_certificates    = ["${local.vault_url}/v1/pki/ca"]
  crl_distribution_points = ["${local.vault_url}/v1/pki/crl"]
}

# resource "vault_pki_secret_backend_role" "root" {
#   backend         = vault_mount.root.path
#   name            = vault_pki_secret_backend_root_cert.root.common_name
#   key_type        = local.cert_algorithm
#   allowed_domains = ["internal.io"]
#   ttl             = local.seconds_1_month
#   max_ttl         = local.seconds_1_month * 6
# }

# resource "vault_pki_secret_backend_issuer" "root" {
#   backend                        = vault_mount.root.path
#   issuer_ref                     = vault_pki_secret_backend_root_cert.root.issuer_id
#   issuer_name                    = vault_pki_secret_backend_root_cert.root.issuer_name
#   revocation_signature_algorithm = title(local.cert_algorithm)
# }

# ----------- intermediate

resource "vault_mount" "int" {
  path                      = "pki_int"
  type                      = "pki"
  default_lease_ttl_seconds = local.seconds_1_month
  max_lease_ttl_seconds     = local.seconds_1_month * 3
}

resource "vault_pki_secret_backend_config_urls" "int" {
  backend                 = vault_mount.int.path
  issuing_certificates    = ["${local.vault_url}/v1/${vault_mount.int.path}/der"]
  crl_distribution_points = ["${local.vault_url}/v1/${vault_mount.int.path}/crl/der"]
  ocsp_servers            = ["${local.vault_url}/v1/${vault_mount.int.path}/ocsp"]
  enable_templating       = true
}

resource "vault_pki_secret_backend_intermediate_cert_request" "int" {
  backend              = vault_mount.int.path
  type                 = "internal"
  common_name          = "trialstudio intermediate"
  key_type             = local.cert_algorithm
  key_bits             = local.cert_algorithm_bits
  exclude_cn_from_sans = true
  alt_names            = [local.base_domain]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "int" {
  backend               = vault_mount.root.path
  common_name           = vault_pki_secret_backend_intermediate_cert_request.int.common_name
  csr                   = vault_pki_secret_backend_intermediate_cert_request.int.csr
  format                = "pem_bundle"
  ttl                   = local.seconds_1_month
  issuer_ref            = vault_pki_secret_backend_root_cert.root.issuer_id
  revoke                = true
  use_csr_values        = true
  permitted_dns_domains = [local.base_domain]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "int" {
  backend     = vault_mount.int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.int.certificate
}

resource "vault_pki_secret_backend_issuer" "intermediate" {
  backend     = vault_mount.int.path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.int.imported_issuers[0]
  issuer_name = "trialstudio-intermediate"
  # revocation_signature_algorithm = title(local.cert_algorithm)
}

resource "vault_pki_secret_backend_role" "int" {
  backend                     = vault_mount.int.path
  issuer_ref                  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  name                        = "trialstudio"
  ttl                         = local.seconds_1_month
  max_ttl                     = local.seconds_1_month * 3
  allow_ip_sans               = true
  key_type                    = local.cert_algorithm
  key_bits                    = local.cert_algorithm_bits
  allowed_domains             = [local.base_domain]
  allow_subdomains            = true
  allow_glob_domains          = true
  allow_wildcard_certificates = true
  require_cn                  = false
}

resource "vault_pki_secret_backend_config_cluster" "int" {
  backend  = vault_mount.int.path
  path     = "${local.vault_url}/v1/${vault_mount.int.path}"
  aia_path = "${local.vault_url}/v1/${vault_mount.int.path}"
}

resource "vault_pki_secret_backend_config_acme" "int" {
  backend         = vault_mount.int.path
  enabled         = true
  allowed_issuers = [vault_pki_secret_backend_intermediate_set_signed.int.imported_issuers[0]]
  allowed_roles   = [vault_pki_secret_backend_role.int.name]
}

resource "vault_generic_endpoint" "pki_int_tune" {
  path                 = "sys/mounts/${vault_mount.int.path}/tune"
  ignore_absent_fields = true
  disable_delete       = true
  data_json            = <<EOT
{
  "allowed_response_headers": [
      "Last-Modified",
      "Location",
      "Replay-Nonce",
      "Link"
    ],
  "passthrough_request_headers": [
    "If-Modified-Since"
  ]
}
EOT
}

resource "vault_generic_endpoint" "int" {
  data_json            = jsonencode({ enabled = true })
  path                 = "${vault_mount.int.path}/config/acme"
  ignore_absent_fields = true
  disable_delete       = true
}
# ------------- leaf

resource "vault_pki_secret_backend_cert" "test" {
  issuer_ref  = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  backend     = vault_pki_secret_backend_role.int.backend
  name        = vault_pki_secret_backend_role.int.name
  common_name = "test.trial.studio"
  ttl         = 3600
  revoke      = true
}
