resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_infra-dmarc-report-viewer_secrets" {
  path         = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/infra-dmarc-report-viewer/secrets"
  disable_read = true
  data_json = jsonencode({
    IMAP_USER     = "FIXME: this should be the username of the smtp-reports mailbox"
    IMAP_PASSWORD = "FIXME: this should be the password of the smtp-reports mailbox"
  })
}
