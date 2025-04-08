# KsqlDB Stream and Table configurations
# This file manages ksqlDB stream and table definitions for the Confluent Cloud cluster.
# Each configuration in ksql_config represents a separate ksqlDB object (stream/table).

locals {
  # Base ksqlDB configurations
  ksql_config = {
    # Simple test stream
    simple_test_stream = {
      name = "SIMPLE_TEST_STREAM"
      sql  = <<-EOT
        CREATE STREAM IF NOT EXISTS SIMPLE_TEST_STREAM (
          name STRING,
          age INTEGER,
          email STRING
        )
        WITH (
          KAFKA_TOPIC = 'simple_test_topic',
          VALUE_FORMAT = 'JSON',
          KEY_FORMAT = 'KAFKA',
          PARTITIONS = 1,
          REPLICAS = 3
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
      
      # Function to make ksqlDB API calls with verbose output
      call_ksqldb() {
        local endpoint="$1"
        local data="$2"
        echo "Debug: Calling endpoint: $endpoint"
        echo "Debug: Request data: $data"
        
        response=$(curl -v -X "POST" "$endpoint" \
          -H "Content-Type: application/vnd.ksql.v1+json" \
          -H "Accept: application/vnd.ksql.v1+json" \
          -u "${confluent_api_key.ksqldb-api-key.id}:${confluent_api_key.ksqldb-api-key.secret}" \
          -d "$data" 2>&1)
        
        echo "Full API Response:"
        echo "$response"
        
        # Return the response
        echo "$response"
      }

      # First verify the topic exists
      echo "Verifying topic 'simple_test_topic' exists..."
      topic_check=$(curl -s -X GET "${local.ck_rest_endpoint}/topics/simple_test_topic" \
        -u "${confluent_api_key.app-manager-api-key.id}:${confluent_api_key.app-manager-api-key.secret}")
      echo "Topic check response: $topic_check"

      # List existing streams before creation
      echo "Listing existing streams before creation..."
      before_list=$(call_ksqldb "${confluent_ksql_cluster.ksql.rest_endpoint}/ksql" '{"ksql": "LIST STREAMS;"}')
      echo "Existing streams: $before_list"

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
      
      echo "Request payload for stream creation:"
      echo "$create_data"
      
      # Make the API call for stream creation
      create_response=$(call_ksqldb "${confluent_ksql_cluster.ksql.rest_endpoint}/ksql" "$create_data")
      echo "Stream creation response: $create_response"
      
      # Verify stream was created by listing streams again
      echo "Verifying stream creation..."
      after_list=$(call_ksqldb "${confluent_ksql_cluster.ksql.rest_endpoint}/ksql" '{"ksql": "LIST STREAMS;"}')
      echo "Updated streams list: $after_list"
      
      # Check if our stream appears in the list
      if ! echo "$after_list" | grep -q "SIMPLE_TEST_STREAM"; then
        echo "Error: SIMPLE_TEST_STREAM not found in streams list after creation"
        exit 1
      fi

      echo "Stream creation verified successfully"
    EOT
  }

  depends_on = [
    confluent_kafka_topic.topics,
    confluent_ksql_cluster.ksql,
    confluent_role_binding.ksqldb_admin,
    confluent_api_key.ksqldb-api-key,
    confluent_api_key.app-manager-api-key
  ]
}

# Simple test resource for ksqlDB functionality
resource "null_resource" "ksql_test" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Running basic ksqlDB test..."
      echo "Endpoint: ${confluent_ksql_cluster.ksql.rest_endpoint}"
      
      # Test listing streams
      response=$(curl -s -X "POST" "${confluent_ksql_cluster.ksql.rest_endpoint}/ksql" \
        -H "Content-Type: application/vnd.ksql.v1+json" \
        -H "Accept: application/vnd.ksql.v1+json" \
        -u "${confluent_api_key.ksqldb-api-key.id}:${confluent_api_key.ksqldb-api-key.secret}" \
        -d '{"ksql": "LIST STREAMS;"}')
      
      echo "Response from ksqlDB:"
      echo "$response"
    EOT
  }

  depends_on = [
    confluent_ksql_cluster.ksql,
    confluent_api_key.ksqldb-api-key
  ]
} 