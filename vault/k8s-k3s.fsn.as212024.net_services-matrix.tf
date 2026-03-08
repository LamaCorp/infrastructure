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
