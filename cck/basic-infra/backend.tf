terraform {
  backend "s3" {
    bucket         = "umb-cck-tfstate"
    key            = "cck/basic-infra/dev.tfstate"
    region         = "us-east-2"
    dynamodb_table = "umb-cck-tfstate-lock"
  }
}
