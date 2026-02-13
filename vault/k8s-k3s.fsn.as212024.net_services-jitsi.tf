resource "random_password" "k8s-k3s-fsn-as212024-net_services-jitsi_jwt-auth" {
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-jitsi_jwt-auth" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-jitsi/jwt-auth"
  data_json = jsonencode({
    JWT_APP_SECRET = random_password.k8s-k3s-fsn-as212024-net_services-jitsi_jwt-auth.result
  })
}

locals {
  rocketchat_instances = toset([
    "sdlh",
    "lama",
  ])
}

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-rocketchat_jitsi-auth" {
  for_each = local.rocketchat_instances
  path     = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-rocketchat-${each.key}/jitsi-auth"
  data_json = jsonencode({
    app_secret = random_password.k8s-k3s-fsn-as212024-net_services-jitsi_jwt-auth.result
  })
}
