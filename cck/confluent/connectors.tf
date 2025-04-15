# Connector configurations - Temporarily commented out for ksqlDB testing
/*
locals {
  # Base connector configurations
  postgres_sink_config = {
    sensitive = {
      "connection.password" = local.env_config.postgres_password
    }
    
    nonsensitive = {
      "connector.class"          = "PostgresSink"
      "name"                     = "${local.ck_env_name}-aurora-postgres-sink"
      "input.data.format"        = "AVRO"
      "kafka.api.key"            = confluent_api_key.postgres-api-key.id
      "kafka.api.secret"         = confluent_api_key.postgres-api-key.secret
      "topics"                   = "unified_records_test"
      "connection.host"          = local.env_config.postgres_host
      "connection.port"          = local.env_config.postgres_port
      "connection.user"          = local.env_config.postgres_user
      "db.name"                 = local.env_config.postgres_database
      
      # Table settings
      "insert.mode"              = "INSERT"
      "table.name.format"        = "stg.sor_data"
      "auto.create"              = "false"
      "auto.evolve"             = "false"
      
      # Performance tuning
      "tasks.max"                = "1"
      "batch.size"               = "3000"
      
      # Error handling
      "errors.tolerance"         = "all"
      "errors.deadletterqueue.topic.name" = "${local.ck_env_name}-postgres-sink-dlq"
      
      # Transformations
      "transforms"                               = "InsertField"
      "transforms.InsertField.type"             = "org.apache.kafka.connect.transforms.InsertField$Value"
      "transforms.InsertField.timestamp.field"  = "kafka_outbound_timestamp"
    }
  }
}

# Create the PostgreSQL sink connector
resource "confluent_connector" "postgres_sink" {
  environment {
    id = data.confluent_environment.env.id
  }
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }

  config_sensitive   = local.postgres_sink_config.sensitive
  config_nonsensitive = local.postgres_sink_config.nonsensitive

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_role_binding.postgres_admin,
    confluent_api_key.postgres-api-key
  ]
}
*/

# PostgreSQL Sink Connector Configuration
resource "confluent_connector" "postgres_sink" {
  environment {
    id = data.confluent_environment.env.id
  }
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }

  config_sensitive = {
    "connection.password" = var.postgress_connection_password
  }

  config_nonsensitive = {
    "connector.class"          = "PostgresSink"
    "name"                    = "postgres_sink"
    "kafka.auth.mode"         = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.postgres.id
    "input.data.format"       = "JSON"
    "connection.host"         = "postgres.umb-bank.com"
    "connection.port"         = "5432"
    "connection.user"         = "postgres"
    "connection.dbname"       = "postgres"
    "db.timezone"            = "UTC"
    "insert.mode"            = "upsert"
    "pk.mode"                = "record_key"
    "pk.fields"              = "id"
    "auto.create"            = "true"
    "auto.evolve"            = "true"
    "delete.enabled"         = "true"
    "tasks.max"              = "1"
    "topics"                 = "postgres_sink_topic"
  }
} 