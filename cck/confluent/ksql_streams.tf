# KsqlDB Stream and Table configurations
locals {
  # Base ksqlDB configurations
  ksql_config = {
    # Stream for CDC customer data
    cdc_customer_stream = {
      name = "CDC_CUSTOMER_O_24201_SOURCE_STREAM"
      sql  = <<-EOT
        CREATE STREAM IF NOT EXISTS cdc_customer_o_24201_source_stream 
        WITH (
          KAFKA_TOPIC = 'cdc_customer_o_24201',
          VALUE_FORMAT = 'AVRO'
        );
      EOT
    }
  }
}

# Create ksqlDB cluster
resource "confluent_ksql_cluster" "main" {
  display_name = "${local.ck_env_name}-ksqldb"
  csu = 1
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
  credential_identity {
    id = confluent_service_account.ksqldb.id
  }
  environment {
    id = data.confluent_environment.env.id
  }
  depends_on = [
    confluent_role_binding.ksqldb_admin
  ]
}

# Create KsqlDB streams and tables
resource "null_resource" "ksql_statements" {
  for_each = local.ksql_config

  triggers = {
    sql_hash = sha256(each.value.sql)
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -X "POST" "${confluent_ksql_cluster.main.rest_endpoint}/ksql" \
        -H "Content-Type: application/vnd.ksql.v1+json" \
        -H "Accept: application/vnd.ksql.v1+json" \
        -u "${confluent_api_key.ksqldb-api-key.id}:${confluent_api_key.ksqldb-api-key.secret}" \
        -d '{
          "ksql": "${replace(each.value.sql, "\n", " ")}",
          "streamsProperties": {}
        }'
    EOT
  }

  depends_on = [
    confluent_ksql_cluster.main,
    confluent_kafka_topic.topics
  ]
} 