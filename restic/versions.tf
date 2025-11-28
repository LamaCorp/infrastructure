terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.5.0"
    }
  }

  backend "http" {}
}

data "vault_generic_secret" "restic_wasabi-credentials" {
  path = "restic/wasabi-credentials"
}

# AWS provider to handle Wasabi S3 conf
provider "aws" {
  region     = "us-east-1"
  access_key = data.vault_generic_secret.restic_wasabi-credentials.data["access_key"]
  secret_key = data.vault_generic_secret.restic_wasabi-credentials.data["secret_key"]

  endpoints {
    iam = "https://iam.wasabisys.com"
    s3  = "https://s3.eu-central-1.wasabisys.com"
    sts = "https://sts.wasabisys.com"
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#s3_use_path_style
  s3_use_path_style = true
}

provider "vault" {}
