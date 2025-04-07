locals {
  # Base topic configurations (common across all environments)
  base_topics = {
    # CDC Account Master Topics
    cdc_account_master_o_1200 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_account_master_o_1201 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_account_master_o_1202 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_account_master_o_1204 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_account_master_o_1208 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_account_master_o_1211 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_account_master_o_1213 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_account_master_o_1225 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_account_master_o_24232 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }

    # CDC Customer Topics
    cdc_customer_o_24201 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24202 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24203 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24204 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24206 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24207 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24208 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24211 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24219 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24273 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_customer_o_24274 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }

    # CDC Addresses Topics
    cdc_addresses_o_24221 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }

    # CDC Relationships Topics
    cdc_relationships_o_24215 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_relationships_o_24216 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_relationships_o_24233 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_relationships_o_24234 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }

    # CDC Restraints Topics
    cdc_restraints_o_5800 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_restraints_o_5803 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_restraints_o_5804 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }

    # CDC Transactions Topics
    cdc_transactions_o_2401 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    cdc_transactions_o_2403 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }

    # JSON Stage Topics
    json_stage_o_1200 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_1201 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_1202 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_1204 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_1208 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_1211 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_1213 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_1225 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_2401 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_2403 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24201 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24202 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24203 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24204 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24206 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24207 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24208 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24211 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24215 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24216 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24219 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24221 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24232 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24233 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24234 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24273 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_24274 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_5800 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_5803 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    json_stage_o_5804 = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }

    # Other Topics
    unified_records = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
    unified_records_test = { partitions_count = 6, retention_ms = 604800000, cleanup_policy = "delete", retention_bytes = -1 }
  }

  # Get environment-specific overrides from YAML
  env_topic_overrides = local.env_config.topics != null ? local.env_config.topics : {}

  # Merge base configurations with environment-specific overrides
  topics = {
    for topic_name, base_config in local.base_topics : topic_name => merge(
      base_config,
      lookup(local.env_topic_overrides, topic_name, {})
    )
  }

  # Create the final topic configurations with tags
  kafka_topics = {
    for topic_name, config in local.topics : topic_name => merge(
      config,
      {
        tags = can(regex("^cdc_", topic_name)) || can(regex("^json_stage_", topic_name)) ? {
          "cdc_customer" = "green"
        } : {}
      }
    )
  }
} 