resource "random_password" "k8s-k3s-fsn-as212024-net_services-dawarich_secrets" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-dawarich_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-dawarich/secrets"
  data_json = jsonencode({
    SECRET_KEY_BASE = random_password.k8s-k3s-fsn-as212024-net_services-dawarich_secrets[0].result
  })
}
