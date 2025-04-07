resource "confluent_environment" "env" {
  display_name = local.ck_env_name
  stream_governance {
    package = "ESSENTIALS"
  }
}

resource "confluent_kafka_cluster" "dedicated" {
  display_name = local.ck_cluster_name
  availability = local.ck_cluster_zone
  cloud        = "AWS"
  region       = local.ck_cluster_region

  dedicated {
    cku = local.ck_cluster_size
  }

  environment {
    id = confluent_environment.env.id
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "time_sleep" "wait_for_sr" {
  create_duration = "60s"
  depends_on      = [confluent_kafka_cluster.dedicated]
}

data "confluent_schema_registry_cluster" "schema_registry" {
  environment {
    id = confluent_environment.env.id
  }
  depends_on = [time_sleep.wait_for_sr]
}
