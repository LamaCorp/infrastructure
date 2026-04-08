terraform {
  required_version = "~> 1.11"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.29.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.8.0"
    }
  }

  backend "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "k3s"
    namespace      = "infra-tfstates"
    secret_suffix  = "grafana"
  }
}

provider "vault" {}

data "vault_generic_secret" "observability_grafana_admin" {
  path = "observability/grafana/admin"
}

provider "grafana" {
  url  = "https://grafana.as212024.net"
  auth = "${data.vault_generic_secret.observability_grafana_admin.data["username"]}:${data.vault_generic_secret.observability_grafana_admin.data["password"]}"
}
