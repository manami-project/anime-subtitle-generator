terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    external = {
      source = "hashicorp/external"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}