# KsqlDB Stream and Table configurations
# This file manages ksqlDB stream and table definitions for the Confluent Cloud cluster.
# Each configuration in ksql_config represents a separate ksqlDB object (stream/table).

locals {
  # Base ksqlDB configurations
  ksql_config = {
    # Stream for CDC customer data
    # This stream captures customer data changes from the CDC topic
    cdc_customer_stream = {
      name = "CDC_CUSTOMER_O_24201_SOURCE_STREAM"
      sql  = <<-EOT
        CREATE STREAM IF NOT EXISTS cdc_customer_o_24201_source_stream (
          -- Add schema definition here to ensure type safety
          -- Example:
          -- id INTEGER,
          -- name STRING,
          -- email STRING
        )
        WITH (
          KAFKA_TOPIC = 'cdc_customer_o_24201',
          VALUE_FORMAT = 'AVRO',
          KEY_FORMAT = 'KAFKA'  -- Explicitly specify key format
        );
      EOT
    }
  }
}

# Create KsqlDB streams and tables
resource "null_resource" "ksql_statements" {
  for_each = local.ksql_config

  triggers = {
    sql_hash = sha256(each.value.sql)
    name     = each.value.name  # Add name to triggers for better tracking
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Attempt to execute ksqlDB statement
      response=$(curl -s -o /dev/null -w "%%{http_code}" -X "POST" "${confluent_ksql_cluster.ksql.rest_endpoint}/ksql" \
        -H "Content-Type: application/vnd.ksql.v1+json" \
        -H "Accept: application/vnd.ksql.v1+json" \
        -u "${confluent_api_key.ksqldb-api-key.id}:${confluent_api_key.ksqldb-api-key.secret}" \
        -d '{
          "ksql": "${replace(each.value.sql, "\n", " ")}",
          "streamsProperties": {
            "ksql.streams.auto.offset.reset": "earliest",
            "ksql.streams.cache.max.bytes.buffering": "0"
          }
        }')

      # Check if the request was successful
      if [ "$response" -ne 200 ]; then
        echo "Failed to create ksqlDB object ${each.value.name}. HTTP status: $response"
        exit 1
      fi
    EOT
  }

  # Add lifecycle block to handle failures
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_ksql_cluster.ksql,
    confluent_role_binding.ksqldb_admin
  ]
} 