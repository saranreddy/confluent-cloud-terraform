output "precisely_api_key" {
  description = "The API key for Precisely service account"
  value       = confluent_api_key.precisely-api-key.id
  sensitive   = true
}

output "precisely_api_secret" {
  description = "The API secret for Precisely service account"
  value       = confluent_api_key.precisely-api-key.secret
  sensitive   = true
} 