terraform {
  required_version = "~> 1.11"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "2.4.0"
    }

    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.3.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.10.1"
    }
  }

  backend "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "k3s"
    namespace      = "infra-tfstates"
    secret_suffix  = "vault"
  }
}
