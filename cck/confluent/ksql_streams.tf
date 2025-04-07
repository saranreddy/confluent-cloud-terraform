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
          KEY_FORMAT = 'KAFKA'
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
    name     = each.value.name
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      # Function to make ksqlDB API calls
      call_ksqldb() {
        local endpoint="$1"
        local data="$2"
        curl -s -X "POST" "$endpoint" \
          -H "Content-Type: application/vnd.ksql.v1+json" \
          -H "Accept: application/vnd.ksql.v1+json" \
          -u "${confluent_api_key.ksqldb-api-key.id}:${confluent_api_key.ksqldb-api-key.secret}" \
          -d "$data"
      }

      # Test cluster connectivity first
      echo "Testing ksqlDB cluster connectivity..."
      info_response=$(call_ksqldb "${confluent_ksql_cluster.ksql.rest_endpoint}/info" "{}")
      echo "Info response: $info_response"
      
      if [ -z "$info_response" ]; then
        echo "Error: No response from ksqlDB cluster"
        exit 1
      fi

      # Try to create the stream
      echo "Attempting to create stream..."
      create_data='{
        "ksql": "${replace(replace(each.value.sql, "\n", " "), "\"", "\\\"")}",
        "streamsProperties": {
          "ksql.streams.auto.offset.reset": "earliest"
        }
      }'
      
      echo "Request payload: $create_data"
      response=$(call_ksqldb "${confluent_ksql_cluster.ksql.rest_endpoint}/ksql" "$create_data")
      echo "Create stream response: $response"

      if [ -z "$response" ]; then
        echo "Error: No response received from create stream request"
        exit 1
      fi

      if echo "$response" | grep -q "error"; then
        echo "Error in response: $response"
        exit 1
      fi

      echo "Stream creation completed"
    EOT
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_ksql_cluster.ksql,
    confluent_role_binding.ksqldb_admin,
    confluent_api_key.ksqldb-api-key
  ]
} 