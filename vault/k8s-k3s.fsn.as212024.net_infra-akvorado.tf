resource "random_password" "k8s-k3s-fsn-as212024-net_infra-akvorado_clickhouse_password" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_infra-akvorado_clickhouse" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/infra-akvorado/clickhouse"
  data_json = jsonencode({
    password = random_password.k8s-k3s-fsn-as212024-net_infra-akvorado_clickhouse_password.result
  })
}
