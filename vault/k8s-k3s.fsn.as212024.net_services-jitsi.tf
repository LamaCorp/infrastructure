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
