terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.23.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.6.0"
    }
  }

  backend "http" {}
}

provider "vault" {}

data "vault_generic_secret" "observability_grafana_admin" {
  path = "observability/grafana/admin"
}

provider "grafana" {
  url  = "https://grafana.as212024.net"
  auth = "${data.vault_generic_secret.observability_grafana_admin.data["username"]}:${data.vault_generic_secret.observability_grafana_admin.data["password"]}"
}
