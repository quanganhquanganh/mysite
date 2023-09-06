terraform {
  backend "remote" {
    organization = "djambda"

    workspaces {
      name = "second-test"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "github" {}
