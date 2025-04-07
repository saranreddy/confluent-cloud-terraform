# Connector configurations
locals {
  # Base connector configurations
  postgres_sink_config = {
    sensitive = {
      "connection.password" = local.env_config.postgres_password
    }
    
    nonsensitive = {
      "connector.class"          = "io.confluent.connect.jdbc.JdbcSinkConnector"
      "name"                     = "${local.ck_env_name}-aurora-postgres-sink"
      "topics"                   = "unified_records_test"
      "connection.host"          = local.env_config.postgres_host
      "connection.port"          = local.env_config.postgres_port
      "connection.user"          = local.env_config.postgres_user
      "database.name"            = local.env_config.postgres_database
      
      # Connection settings
      "ssl.mode"                 = "prefer"
      "input.data.format"        = "AVRO"
      
      # Table settings
      "insert.mode"              = "INSERT"
      "table.name.format"        = "\"stg\".sor_data"
      "table.types"              = "TABLE"
      "pk.mode"                  = "none"
      "auto.create"              = "false"
      "auto.add.columns"         = "false"
      "delete.on.null"           = "false"
      
      # Performance tuning
      "tasks.max"                = "1"
      "batch.size"               = "3000"
      "quote.sql.identifiers"    = "ALWAYS"
      "schema.context"           = "default"
      "max.poll.interval.ms"     = "300000"
      "max.poll.records"         = "500"
      
      # Timezone settings
      "database.timezone"        = "UTC"
      "timezone.used.for.date"   = "DB_TIMEZONE"
      
      # Error handling
      "errors.tolerance"         = "all"
      "errors.deadletterqueue.topic.name" = "${local.ck_env_name}-postgres-sink-dlq"
      "errors.deadletterqueue.topic.replication.factor" = "3"
      
      # Transformations
      "transforms"                               = "transform_0"
      "transforms.transform_0.type"              = "org.apache.kafka.connect.transforms.InsertField$Value"
      "transforms.transform_0.timestamp.field"   = "kafka_outbound_timestamp"
      "transforms.transform_0.replace.null.with.default" = "true"
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
    prevent_destroy = true
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_role_binding.postgres_admin
  ]
} 