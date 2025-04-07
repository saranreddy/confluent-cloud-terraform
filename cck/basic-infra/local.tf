locals {
  env_settings      = yamldecode(file("../../environments/${terraform.workspace}.yaml"))
  global_settings   = yamldecode(file("../../environments/global.yaml"))
  global_config     = local.global_settings.global
  env_config        = local.env_settings.env

  ck_env_name       = local.env_config.ck_env_name
  ck_cluster_name   = local.env_config.ck_cluster_name
  ck_cluster_zone   = local.env_config.ck_cluster_zone
  ck_cluster_size   = local.env_config.ck_cluster_size
  ck_cluster_region = local.global_config.ck_cluster_region
}
