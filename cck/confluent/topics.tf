locals {
  # Get base topic configurations from global settings
  base_topics = local.global_config.base_topics

  # Get default topic settings
  topic_defaults = local.global_config.topic_defaults

  # Get environment-specific overrides from YAML
  env_topic_overrides = local.env_config.topics != null ? local.env_config.topics : {}

  # Merge base configurations with environment-specific overrides
  topics = {
    for topic_name, base_config in local.base_topics : topic_name => merge(
      local.topic_defaults,  # Apply defaults first
      base_config,          # Then base config (can override defaults)
      lookup(local.env_topic_overrides, topic_name, {})  # Finally env-specific overrides
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