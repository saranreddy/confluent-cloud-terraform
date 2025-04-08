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
      
      # Configure Confluent CLI with the API key
      echo "Configuring Confluent CLI..."
      export CONFLUENT_CLOUD_API_KEY="${confluent_api_key.ksqldb-api-key.id}"
      export CONFLUENT_CLOUD_API_SECRET="${confluent_api_key.ksqldb-api-key.secret}"
      
      # Create a temporary file for the SQL statement
      SQL_FILE=$(mktemp)
      echo "${each.value.sql}" > "$SQL_FILE"
      
      echo "SQL File contents:"
      cat "$SQL_FILE"
      
      # First, verify the topic exists using Confluent CLI
      echo "Verifying topic 'simple_test_topic' exists..."
      if ! confluent kafka topic list | grep -q "simple_test_topic"; then
        echo "Error: Topic 'simple_test_topic' not found"
        rm "$SQL_FILE"
        exit 1
      fi
      
      # List existing streams before creation
      echo "Listing existing streams before creation..."
      confluent ksql cluster list
      
      # Get the ksqlDB cluster ID
      KSQLDB_ENDPOINT="${confluent_ksql_cluster.ksql.rest_endpoint}"
      KSQLDB_CLUSTER_ID=$(echo "$KSQLDB_ENDPOINT" | cut -d'/' -f3 | cut -d'.' -f1)
      
      echo "Using ksqlDB cluster ID: $KSQLDB_CLUSTER_ID"
      
      # Use the Confluent CLI to execute the ksqlDB statement
      echo "Creating stream using Confluent CLI..."
      confluent ksql cluster use "$KSQLDB_CLUSTER_ID"
      
      # Execute the SQL statement
      confluent ksql statement execute --file "$SQL_FILE"
      CREATE_STATUS=$?
      
      # Clean up the temporary file
      rm "$SQL_FILE"
      
      if [ $CREATE_STATUS -ne 0 ]; then
        echo "Error: Failed to create stream"
        exit 1
      fi
      
      # Verify the stream was created
      echo "Verifying stream creation..."
      if ! confluent ksql statement execute --cluster "$KSQLDB_CLUSTER_ID" --content-type "application/vnd.ksql.v1+json" '{"ksql": "LIST STREAMS;"}' | grep -q "SIMPLE_TEST_STREAM"; then
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