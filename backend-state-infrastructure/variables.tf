variable "aws_region" {
  description = "The AWS Region to deploy the resources in"
  type        = string
  default     = "us-east-2"
}

variable "common_short_name" {
  description = "Application name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

# variable "aws_account_number" {
#   description = "AWS acc number"
#   type        = string
# }
