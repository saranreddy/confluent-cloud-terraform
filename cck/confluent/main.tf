
# Fetch existing confluent kafka components
data "confluent_environment" "env" {
  display_name = local.ck_env_name
}

data "confluent_kafka_cluster" "cluster" {
  display_name = local.ck_cluster_name
  environment {
    id = data.confluent_environment.env.id
  }
}

data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = data.confluent_environment.env.id
  }
}

# Service accounts
resource "confluent_service_account" "app-manager" {
  display_name = "${local.ck_env_name}-app-manager-sa"
  description  = "Service account for app-manager"
}

resource "confluent_service_account" "postgres" {
  display_name = "${local.ck_env_name}-postgres-sink-sa"
  description  = "Service account for postgres"
}

resource "confluent_service_account" "precisely" {
  display_name = "${local.ck_env_name}-precisely-sa"
  description  = "Service account for precisely"
}

resource "confluent_service_account" "ksqldb" {
  display_name = "${local.ck_env_name}-ksqldb-sa"
  description  = "Service account for ksqldb"
}

resource "confluent_service_account" "snowflake" {
  display_name = "${local.ck_env_name}-snowflake-sink-sa"
  description  = "Service account for snowflake"
}

# Role bindings
resource "confluent_role_binding" "app-manager_admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.cluster.rbac_crn
}

resource "confluent_role_binding" "postgres_admin" {
  principal   = "User:${confluent_service_account.postgres.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.cluster.rbac_crn
}

resource "confluent_role_binding" "precisely_admin" {
  principal   = "User:${confluent_service_account.precisely.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.cluster.rbac_crn
}

resource "confluent_role_binding" "ksqldb_admin" {
  principal   = "User:${confluent_service_account.ksqldb.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.cluster.rbac_crn
}

resource "confluent_role_binding" "snowflake_admin" {
  principal   = "User:${confluent_service_account.snowflake.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.cluster.rbac_crn
}

# API Keys
resource "confluent_api_key" "app-manager-api-key" {
  display_name = "app-manager-api-key"
  description  = "app-manager API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }
  managed_resource {
    id          = data.confluent_kafka_cluster.cluster.id
    api_version = data.confluent_kafka_cluster.cluster.api_version
    kind        = data.confluent_kafka_cluster.cluster.kind
    environment {
      id = data.confluent_environment.env.id
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_api_key" "postgres-api-key" {
  display_name = "postgres-api-key"
  description  = "postgres API Key that is owned by 'postgres' service account"
  owner {
    id          = confluent_service_account.postgres.id
    api_version = confluent_service_account.postgres.api_version
    kind        = confluent_service_account.postgres.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.cluster.id
    api_version = data.confluent_kafka_cluster.cluster.api_version
    kind        = data.confluent_kafka_cluster.cluster.kind

    environment {
      id = data.confluent_environment.env.id
    }
  }

  lifecycle {
    prevent_destroy = true
  }

}

resource "confluent_api_key" "precisely-api-key" {
  display_name = "precisely-api-key"
  description  = "precisely API Key that is owned by 'precisely' service account"
  owner {
    id          = confluent_service_account.precisely.id
    api_version = confluent_service_account.precisely.api_version
    kind        = confluent_service_account.precisely.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.cluster.id
    api_version = data.confluent_kafka_cluster.cluster.api_version
    kind        = data.confluent_kafka_cluster.cluster.kind

    environment {
      id = data.confluent_environment.env.id
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}


resource "confluent_api_key" "ksqldb-api-key" {
  display_name = "ksqldb-api-key"
  description  = "KsqlDB API Key that is owned by 'ksqldb' service account"
  owner {
    id          = confluent_service_account.ksqldb.id
    api_version = confluent_service_account.ksqldb.api_version
    kind        = confluent_service_account.ksqldb.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.cluster.id
    api_version = data.confluent_kafka_cluster.cluster.api_version
    kind        = data.confluent_kafka_cluster.cluster.kind

    environment {
      id = data.confluent_environment.env.id
    }
  }
  
  lifecycle {
    prevent_destroy = true
  }

}

resource "confluent_api_key" "snowflake-api-key" {
  display_name = "snowflake-api-key"
  description  = "snowflake API Key that is owned by 'snowflake' service account"
  owner {
    id          = confluent_service_account.snowflake.id
    api_version = confluent_service_account.snowflake.api_version
    kind        = confluent_service_account.snowflake.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.cluster.id
    api_version = data.confluent_kafka_cluster.cluster.api_version
    kind        = data.confluent_kafka_cluster.cluster.kind

    environment {
      id = data.confluent_environment.env.id
    }
  }

  lifecycle {
    prevent_destroy = true
  }

}


# Read existing SA Terraform

data "confluent_service_account" "existing-SA" {
  display_name = "Terraform"
}

resource "confluent_api_key" "env-manager-schema-registry-api-key" {
  display_name = "env-manager-schema-registry-api-key"
  description  = "Schema Registry API Key that is owned by 'Terraform' service account"
  owner {
    id          = data.confluent_service_account.existing-SA.id
    api_version = data.confluent_service_account.existing-SA.api_version
    kind        = data.confluent_service_account.existing-SA.kind
  }

  managed_resource {
    id          = data.confluent_schema_registry_cluster.essentials.id
    api_version = data.confluent_schema_registry_cluster.essentials.api_version
    kind        = data.confluent_schema_registry_cluster.essentials.kind

    environment {
      id = data.confluent_environment.env.id
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create ksqlDB cluster
resource "confluent_ksql_cluster" "ksql" {
  display_name = "ksqlDB_cluster_0"
  csu          = "${local.ck_csu}"
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

# Create all topics using a single resource block
resource "confluent_kafka_topic" "topics" {
  for_each = local.kafka_topics
  kafka_cluster {
    id = data.confluent_kafka_cluster.cluster.id
  }
  topic_name       = each.key
  partitions_count = each.value.partitions_count
  rest_endpoint    = local.ck_rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-api-key.id
    secret = confluent_api_key.app-manager-api-key.secret
  }
  config = {
    "cleanup.policy"  = each.value.cleanup_policy
    "retention.ms"    = each.value.retention_ms
    "retention.bytes" = each.value.retention_bytes
  }
}
