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
    name     = each.value.name
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      # Wait for ksqlDB cluster to be ready (retry for 5 minutes)
      max_retries=30
      retry_count=0
      while [ "$retry_count" -lt "$max_retries" ]; do
        status_code=$(curl -s -o /dev/null -w "%%{http_code}" \
          "${confluent_ksql_cluster.ksql.rest_endpoint}/info" \
          -H "Accept: application/vnd.ksql.v1+json" \
          -u "${confluent_api_key.ksqldb-api-key.id}:${confluent_api_key.ksqldb-api-key.secret}")
        
        if [ "$status_code" = "200" ]; then
          break
        fi
        echo "Waiting for ksqlDB cluster to be ready... (Attempt $((retry_count + 1)) of $max_retries)"
        sleep 10
        retry_count=$((retry_count + 1))
      done

      if [ "$retry_count" -eq "$max_retries" ]; then
        echo "Error: ksqlDB cluster not ready after 5 minutes"
        exit 1
      fi

      # Attempt to execute ksqlDB statement with proper JSON escaping
      response=$(curl -s -X "POST" "${confluent_ksql_cluster.ksql.rest_endpoint}/ksql" \
        -H "Content-Type: application/vnd.ksql.v1+json" \
        -H "Accept: application/vnd.ksql.v1+json" \
        -u "${confluent_api_key.ksqldb-api-key.id}:${confluent_api_key.ksqldb-api-key.secret}" \
        -d @- <<CURL_DATA
{
  "ksql": "${replace(replace(each.value.sql, "\n", " "), "\"", "\\\"")}",
  "streamsProperties": {
    "ksql.streams.auto.offset.reset": "earliest",
    "ksql.streams.cache.max.bytes.buffering": "0"
  }
}
CURL_DATA
)

      # Print full response for debugging
      echo "ksqlDB Response: $response"

      # Check if the response contains an error message
      if echo "$response" | grep -q '"error_code":'; then
        echo "Failed to create ksqlDB object ${each.value.name}. Error response: $response"
        exit 1
      fi

      # Check if the response indicates success
      if ! echo "$response" | grep -q '"commandStatus":"SUCCESS"'; then
        echo "Failed to create ksqlDB object ${each.value.name}. Unexpected response: $response"
        exit 1
      fi
    EOT
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_ksql_cluster.ksql,
    confluent_role_binding.ksqldb_admin,
    confluent_api_key.ksqldb-api-key
  ]
} 