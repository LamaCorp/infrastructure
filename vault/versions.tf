terraform {
  required_version = "~> 1.11"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }

    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.9.0"
    }
  }

  backend "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "k3s"
    namespace      = "infra-tfstates"
    secret_suffix  = "vault"
  }
}
