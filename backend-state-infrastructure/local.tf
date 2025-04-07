locals {
  s3_bucket      = "umb-cck-tfstate"
  dynamodb_table = "umb-cck-tfstate-lock"

  tags = {
    Project     = "confluent-cloud"
    Environment = var.env
    App         = var.common_short_name
  }
}
