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

variable "cc_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "cc_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}


variable "postgress_connection_password" {
  description = "postgress_connection_password"
  type        = string
  sensitive   = true
}
