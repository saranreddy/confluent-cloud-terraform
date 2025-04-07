terraform {
  backend "s3" {
    bucket         = "umb-cck-tfstate"
    key            = "cck/confluent/state.tfstate" #your bucket path
    region         = "us-east-2"
    dynamodb_table = "umb-cck-tfstate-lock"
  }
}
