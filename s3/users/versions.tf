terraform {
  required_providers {
    assert = {
      source  = "bwoznicki/assert"
      version = "0.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.6.0"
    }
  }

  backend "http" {}
}
