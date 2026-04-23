terraform {
  required_version = "~> 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.42.0"
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
    secret_suffix  = "aws-ses"
  }
}

data "vault_generic_secret" "infra_aws_root" {
  path = "infra/aws/root"
}
provider "aws" {
  region     = "eu-west-3"
  access_key = data.vault_generic_secret.infra_aws_root.data["access_key"]
  secret_key = data.vault_generic_secret.infra_aws_root.data["secret_key"]
}
