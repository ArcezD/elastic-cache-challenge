terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.44.0"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.region
}

provider "template" {
  # Configuration options
}