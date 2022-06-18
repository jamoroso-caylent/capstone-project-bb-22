terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72, <= 4.18.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10, < 2.12"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1, <= 2.5.1"
    }
  }
}