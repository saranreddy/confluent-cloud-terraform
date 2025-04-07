# Local variables for ksqlDB configuration
locals {
  ksql_endpoint = confluent_ksql_cluster.ksql.rest_endpoint
  ksql_streams = {
    cdc_customer_o_24201_source_stream = {
      statement = <<-EOT
        CREATE STREAM IF NOT EXISTS cdc_customer_o_24201_source_stream 
        WITH (VALUE_FORMAT='AVRO', KAFKA_TOPIC='cdc_customer_o_24201');
      EOT
    }
  }
}

# Create a script to execute ksqlDB statements
resource "local_file" "ksql_script" {
  filename = "${path.module}/scripts/execute_ksql.sh"
  content  = <<-EOT
    #!/bin/bash
    set -e

    KSQL_ENDPOINT="$1"
    API_KEY="$2"
    API_SECRET="$3"
    STATEMENT="$4"

    # Execute ksqlDB statement
    curl -X POST "${KSQL_ENDPOINT}/ksql" \
      -H "Content-Type: application/vnd.ksql.v1+json" \
      -u "${API_KEY}:${API_SECRET}" \
      -d @- << EOF
    {
      "ksql": "$STATEMENT",
      "streamsProperties": {}
    }
EOF
  EOT

  # Make the script executable
  provisioner "local-exec" {
    command = "chmod +x ${self.filename}"
  }
}

# Create ksqlDB streams
resource "null_resource" "create_ksql_streams" {
  for_each = local.ksql_streams

  triggers = {
    stream_definition = each.value.statement
    script_hash      = local_file.ksql_script.content
  }

  provisioner "local-exec" {
    command = "${local_file.ksql_script.filename} '${local.ksql_endpoint}' '${confluent_api_key.ksqldb-api-key.id}' '${confluent_api_key.ksqldb-api-key.secret}' '${replace(each.value.statement, "\n", " ")}'"
  }

  depends_on = [
    confluent_ksql_cluster.ksql,
    confluent_api_key.ksqldb-api-key,
    local_file.ksql_script,
    confluent_kafka_topic.topics
  ]
} 