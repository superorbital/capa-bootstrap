terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "~> 2.4"
    }
  }
  required_version = ">= 1.0.0"
}
