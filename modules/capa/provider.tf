terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.1.0"
    }
  }
  required_version = ">= 1.0.0"
}
