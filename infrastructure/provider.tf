terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.55.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "2.3.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.3.0"
    }
    external = {
      source = "hashicorp/external"
      version = "2.2.3"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project = local.project_name
    }
  }
}