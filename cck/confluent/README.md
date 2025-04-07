# Confluent Cloud Infrastructure Management

This repository contains Terraform configurations for managing Confluent Cloud infrastructure.

## Table of Contents
1. [Topic Management](#topic-management)
   - [Adding New Topics](#adding-new-topics)
   - [Topic Configuration Options](#topic-configuration-options)
   - [Topic Best Practices](#topic-best-practices)
   - [Example Topic Configurations](#example-topic-configurations)
   - [Topic Troubleshooting](#topic-troubleshooting)
2. [Connector Management](#connector-management)
   - [Adding New Connectors](#adding-new-connectors)
   - [Example Connectors](#example-connectors)
   - [Connector Configuration](#connector-configuration)
   - [Connector Best Practices](#connector-best-practices)
   - [Connector Troubleshooting](#connector-troubleshooting)

---

## Topic Management

### Adding New Topics

1. **Add Base Topic Configuration**
   Add the new topic to the base configuration in `topics.tf`:
   ```hcl
   base_topics = {
     your_new_topic = {
       partitions_count = 6
       retention_ms    = 604800000  # 7 days
       cleanup_policy  = "delete"
       retention_bytes = -1         # unlimited
     }
   }
   ```

2. **Configure Environment-Specific Settings (Optional)**
   Add overrides in environment YAML files:
   ```yaml
   # environments/dev.yaml
   topics:
     your_new_topic:
       partitions_count: 6
       retention_ms: 86400000  # 1 day
   ```

3. **Apply Changes**
   ```bash
   terraform workspace select dev  # or staging/prod
   terraform apply
   ```

### Topic Configuration Options

#### Required Settings
- `partitions_count`: Number of partitions for the topic
- `retention_ms`: Message retention time in milliseconds
- `cleanup_policy`: Topic cleanup policy (e.g., "delete", "compact")
- `retention_bytes`: Message retention size in bytes (-1 for unlimited)

#### Common Retention Periods
- 1 hour: 3600000
- 1 day: 86400000
- 3 days: 259200000
- 7 days: 604800000
- 30 days: 2592000000

### Topic Best Practices

1. **Partition Count**
   - Start with 6 partitions for new topics
   - Increase based on expected throughput
   - Consider future scaling needs

2. **Retention**
   - Set appropriate retention based on data importance
   - Consider storage costs
   - Align with business requirements

3. **Environment Differences**
   - Use shorter retention in non-prod environments
   - Consider lower partition counts in dev/staging
   - Match production configuration for staging

4. **Naming Conventions**
   - Use descriptive names
   - Follow existing patterns (e.g., cdc_*, json_stage_*)
   - Include environment indicators if needed

### Example Topic Configurations

```hcl
# CDC Topic
cdc_customer_data = {
  partitions_count = 12
  retention_ms    = 604800000  # 7 days
  cleanup_policy  = "delete"
  retention_bytes = -1
}

# JSON Stage Topic
json_stage_events = {
  partitions_count = 6
  retention_ms    = 86400000  # 1 day
  cleanup_policy  = "delete"
  retention_bytes = -1
}
```

### Topic Troubleshooting

1. **Topic Creation Fails**
   - Check API key permissions
   - Verify environment settings
   - Ensure topic name follows conventions

2. **Configuration Not Applied**
   - Verify YAML syntax
   - Check workspace selection
   - Confirm environment overrides

---

## Connector Management

### Adding New Connectors

1. **Define Connector Configuration**
   Add your connector configuration to `connectors.tf`:
   ```hcl
   locals {
     new_connector_config = {
       sensitive = {
         "connection.password" = local.env_config.some_password
       }
       nonsensitive = {
         "connector.class" = "YourConnectorClass"
         "name"           = "${local.ck_env_name}-your-connector-name"
         "topics"         = "your-topic-name"
       }
     }
   }
   ```

2. **Create Connector Resource**
   ```hcl
   resource "confluent_connector" "your_connector" {
     environment {
       id = data.confluent_environment.env.id
     }
     kafka_cluster {
       id = data.confluent_kafka_cluster.cluster.id
     }

     config_sensitive   = local.your_connector_config.sensitive
     config_nonsensitive = local.your_connector_config.nonsensitive

     lifecycle {
       prevent_destroy = true
     }
   }
   ```

### Example Connectors

#### 1. PostgreSQL Sink Connector
```hcl
locals {
  postgres_sink_config = {
    sensitive = {
      "connection.password" = local.env_config.postgres_password
    }
    nonsensitive = {
      "connector.class"     = "io.confluent.connect.jdbc.JdbcSinkConnector"
      "name"               = "${local.ck_env_name}-postgres-sink"
      "topics"             = "your-topic"
      "connection.host"    = local.env_config.postgres_host
      "connection.port"    = local.env_config.postgres_port
      "connection.user"    = local.env_config.postgres_user
      "database.name"      = local.env_config.postgres_database
      "ssl.mode"          = "prefer"
      "input.data.format" = "AVRO"
      "insert.mode"       = "INSERT"
      "table.name.format" = "schema.table_name"
      "tasks.max"         = "1"
      "batch.size"        = "3000"
    }
  }
}
```

#### 2. Snowflake Sink Connector
```hcl
locals {
  snowflake_sink_config = {
    sensitive = {
      "snowflake.private.key" = local.env_config.snowflake_private_key
    }
    nonsensitive = {
      "connector.class"    = "SnowflakeSink"
      "name"              = "${local.ck_env_name}-snowflake-sink"
      "topics"            = "your-topic"
      "snowflake.url"     = local.env_config.snowflake_url
      "snowflake.user"    = local.env_config.snowflake_user
      "snowflake.database" = local.env_config.snowflake_database
      "tasks.max"         = "1"
    }
  }
}
```

### Connector Configuration

Add connector-specific configurations to your environment YAML files:
```yaml
env:
  # PostgreSQL Configuration
  postgres_host: "your-host"
  postgres_port: "5432"
  postgres_user: "your-user"
  postgres_password: "your-password"
  postgres_database: "your-database"

  # Snowflake Configuration
  snowflake_url: "your-account.snowflakecomputing.com"
  snowflake_user: "your-user"
  snowflake_private_key: "your-private-key"
  snowflake_database: "your-database"
```

### Connector Best Practices

1. **Security**
   - Separate sensitive and non-sensitive configurations
   - Use environment variables or secure vaults
   - Follow least privilege principle

2. **Configuration Management**
   - Use environment-specific configurations
   - Keep configurations modular
   - Document all options

3. **Error Handling**
   - Configure Dead Letter Queues (DLQ)
   - Set appropriate error tolerance
   - Monitor connector status

4. **Performance**
   - Configure appropriate batch sizes
   - Set optimal task numbers
   - Monitor throughput

### Connector Troubleshooting

1. **Creation Issues**
   - Verify service account permissions
   - Check configuration values
   - Ensure target system access

2. **Connection Problems**
   - Check network connectivity
   - Verify credentials
   - Validate SSL/TLS settings

3. **Performance Issues**
   - Review batch settings
   - Check task count
   - Monitor resource usage

### Common Commands
```bash
# View status
terraform show

# Plan changes
terraform plan

# Apply changes
terraform apply

# Remove connector
terraform destroy -target=confluent_connector.your_connector
``` 