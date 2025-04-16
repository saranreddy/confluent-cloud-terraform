terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.36"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.19.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "confluent" {
  cloud_api_key    = var.cc_api_key
  cloud_api_secret = var.cc_api_secret
}
