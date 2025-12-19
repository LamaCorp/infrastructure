resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-mastodon_vapid-key" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-mastodon/vapid-key"
  disable_read = true
  data_json = jsonencode({
    VAPID_PRIVATE_KEY = "FIXME"
    VAPID_PUBLIC_KEY  = "FIXME"
  })
}

resource "random_password" "k8s-k3s-fsn-as212024-net_services-mastodon_secrets" {
  count   = 5
  length  = 128
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-mastodon_secrets" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-mastodon/secrets"
  data_json = jsonencode({
    SECRET_KEY_BASE                              = random_password.k8s-k3s-fsn-as212024-net_services-mastodon_secrets[0].result
    OTP_SECRET                                   = random_password.k8s-k3s-fsn-as212024-net_services-mastodon_secrets[1].result
    ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY   = random_password.k8s-k3s-fsn-as212024-net_services-mastodon_secrets[2].result
    ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT = random_password.k8s-k3s-fsn-as212024-net_services-mastodon_secrets[3].result
    ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY         = random_password.k8s-k3s-fsn-as212024-net_services-mastodon_secrets[4].result
  })
}
