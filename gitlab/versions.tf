terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.11.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.8.2"
    }
  }

  required_version = "< 1.15.0"

  backend "http" {}
}

variable "gitlab_base_url" {
  type        = string
  default     = "https://gitlab.com/api/v4/"
  description = "GitLab API base URL"
}

variable "gitlab_token" {
  type        = string
  description = "Token to authenticate to the GitLab API"
  sensitive   = true
}

provider "gitlab" {
  base_url = var.gitlab_base_url
  token    = var.gitlab_token
}

variable "github_token" {
  type        = string
  description = "Token to authenticate to the GitHub API"
  sensitive   = true
}

provider "github" {
  token = var.github_token
  owner = "lamacorp"
}

variable "github_mirroring_token" {
  type        = string
  description = "Token used to mirror repositories to GitHub"
  sensitive   = true
}
