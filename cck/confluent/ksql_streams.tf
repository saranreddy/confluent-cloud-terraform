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
      # Print detailed debug information about the ksqlDB cluster
      echo "Debug: ksqlDB Cluster Information:"
      echo "  - Endpoint: ${confluent_ksql_cluster.ksql.rest_endpoint}"
      echo "  - Cluster Name: ${confluent_ksql_cluster.ksql.display_name}"
      echo "  - Environment ID: ${confluent_ksql_cluster.ksql.environment[0].id}"
      echo "  - API Key ID: ${confluent_api_key.ksqldb-api-key.id}"
      
      # Test basic connectivity first with verbose output
      echo "Testing basic connectivity to cluster ${confluent_ksql_cluster.ksql.display_name}..."
      curl -v "${confluent_ksql_cluster.ksql.rest_endpoint}" 2>&1
      
      # Function to make ksqlDB API calls with verbose output
      call_ksqldb() {
        local endpoint="$1"
        local data="$2"
        echo "Debug: Calling endpoint: $endpoint"
        echo "Debug: Request data: $data"
        
        # Use -v for verbose output and include HTTP headers
        curl -v -X "POST" "$endpoint" \
          -H "Content-Type: application/vnd.ksql.v1+json" \
          -H "Accept: application/vnd.ksql.v1+json" \
          -u "${confluent_api_key.ksqldb-api-key.id}:${confluent_api_key.ksqldb-api-key.secret}" \
          -d "$data" 2>&1
      }

      # First, try to list existing streams
      echo "Attempting to list existing streams on cluster ${confluent_ksql_cluster.ksql.display_name}..."
      list_response=$(call_ksqldb "${confluent_ksql_cluster.ksql.rest_endpoint}/ksql" '{"ksql": "LIST STREAMS;"}')
      echo "List streams response: $list_response"

      # Try to create the stream with explicit error handling
      echo "Attempting to create stream on cluster ${confluent_ksql_cluster.ksql.display_name}..."
      create_data=$(cat <<EOF
{
  "ksql": "${replace(replace(each.value.sql, "\n", " "), "\"", "\\\"")}",
  "streamsProperties": {
    "ksql.streams.auto.offset.reset": "earliest"
  }
}
EOF
)
      
      echo "Request payload: $create_data"
      
      # Make the API call with full debugging
      response=$(call_ksqldb "${confluent_ksql_cluster.ksql.rest_endpoint}/ksql" "$create_data")
      status=$?
      
      echo "Debug: curl exit status: $status"
      echo "Debug: Response: $response"
      
      # Check curl exit status
      if [ $status -ne 0 ]; then
        echo "Error: curl command failed with status $status"
        exit 1
      fi

      # Check for empty response
      if [ -z "$response" ]; then
        echo "Error: Empty response from server"
        exit 1
      fi

      # Check for error in response
      if echo "$response" | grep -q '"error\|ERROR\|error_code"'; then
        echo "Error in response: $response"
        exit 1
      fi

      echo "Stream creation completed successfully on cluster ${confluent_ksql_cluster.ksql.display_name}"
    EOT
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_ksql_cluster.ksql,
    confluent_role_binding.ksqldb_admin,
    confluent_api_key.ksqldb-api-key
  ]
} 