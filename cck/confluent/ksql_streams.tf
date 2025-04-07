# KsqlDB Stream and Table configurations
locals {
  # Base ksqlDB configurations
  ksql_config = {
    # Stream for unified records
    unified_records_stream = {
      name = "UNIFIED_RECORDS_STREAM"
      sql  = <<-EOT
        CREATE STREAM IF NOT EXISTS UNIFIED_RECORDS_STREAM (
          RECORD_ID VARCHAR,
          CUSTOMER_ID VARCHAR,
          ACCOUNT_NUMBER VARCHAR,
          TRANSACTION_TYPE VARCHAR,
          TRANSACTION_AMOUNT DECIMAL(10,2),
          TRANSACTION_TIMESTAMP TIMESTAMP
        ) WITH (
          KAFKA_TOPIC = 'unified_records',
          VALUE_FORMAT = 'AVRO',
          TIMESTAMP = 'TRANSACTION_TIMESTAMP'
        );
      EOT
    }

    # Table for customer aggregations
    customer_transactions_table = {
      name = "CUSTOMER_TRANSACTIONS"
      sql  = <<-EOT
        CREATE TABLE IF NOT EXISTS CUSTOMER_TRANSACTIONS
        WITH (
          KAFKA_TOPIC = '${local.ck_env_name}_customer_transactions',
          VALUE_FORMAT = 'AVRO',
          PARTITIONS = 6,
          REPLICAS = 3
        ) AS
        SELECT
          CUSTOMER_ID,
          COUNT(*) AS TOTAL_TRANSACTIONS,
          SUM(TRANSACTION_AMOUNT) AS TOTAL_AMOUNT,
          LATEST_BY_OFFSET(ACCOUNT_NUMBER) AS LAST_ACCOUNT,
          COLLECT_LIST(TRANSACTION_TYPE) AS TRANSACTION_TYPES
        FROM UNIFIED_RECORDS_STREAM
        WINDOW TUMBLING (SIZE 24 HOURS)
        GROUP BY CUSTOMER_ID;
      EOT
    }
  }
}

# Create ksqlDB statements
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