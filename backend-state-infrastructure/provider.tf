terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.36"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
