output "s3_bucket" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.mybucket.bucket
}

output "dynamodb_table" {
  description = "Name of the created DynamoDB table"
  value       = aws_dynamodb_table.mydynamodbtable.name
}
