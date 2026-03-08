### Homeserver

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-matrix_synapse_signing-key" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-matrix/synapse/signing-key"
  disable_read = true
  data_json = jsonencode({
    key = "FIXME"
  })
}

resource "random_password" "k8s-k3s-fsn-as212024-net_services-matrix_synapse_secrets" {
  count   = 3
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-matrix_synapse_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-matrix/synapse/secrets"
  data_json = jsonencode({
    form_secret         = random_password.k8s-k3s-fsn-as212024-net_services-matrix_synapse_secrets[0].result
    macaroon_secret_key = random_password.k8s-k3s-fsn-as212024-net_services-matrix_synapse_secrets[1].result
    auth_shared_secret  = random_password.k8s-k3s-fsn-as212024-net_services-matrix_synapse_secrets[2].result
  })
}

### App services

locals {
  k8s-k3s-fsn-as212024-net_services-matrix_appservices = toset([
    "mautrix-slack",
  ])
}

resource "random_password" "k8s-k3s-fsn-as212024-net_services-matrix_appservices-as-tokens" {
  for_each = local.k8s-k3s-fsn-as212024-net_services-matrix_appservices
  length   = 64
  special  = false
}
resource "random_password" "k8s-k3s-fsn-as212024-net_services-matrix_appservices-hs-tokens" {
  for_each = local.k8s-k3s-fsn-as212024-net_services-matrix_appservices
  length   = 64
  special  = false
}

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-matrix_appservices" {
  for_each = local.k8s-k3s-fsn-as212024-net_services-matrix_appservices
  path     = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-matrix/appservices/${each.key}"
  data_json = jsonencode({
    hs_token = random_password.k8s-k3s-fsn-as212024-net_services-matrix_appservices-hs-tokens[each.key].result
    as_token = random_password.k8s-k3s-fsn-as212024-net_services-matrix_appservices-as-tokens[each.key].result
  })
}

### Mautrix slack

resource "random_password" "k8s-k3s-fsn-as212024-net_services-matrix_mautrix-slack_secrets" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-matrix_mautrix-slack_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-matrix/mautrix-slack/secrets"
  data_json = jsonencode({
    encryption_secret = random_password.k8s-k3s-fsn-as212024-net_services-matrix_mautrix-slack_secrets[0].result
  })
}
