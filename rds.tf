locals {
  rds_enabled           = module.this.enabled && var.rds_enabled
  rds_instance_type     = coalesce(var.rds_instance_type, (module.this.stage == "prod") ? "db.t3.small" : "db.t3.medium")
  rds_allocated_disk_gb = coalesce(var.rds_allocated_disk_gb, (module.this.stage == "prod") ? 30 : 10)
}

resource "random_password" "metamigo" {
  count = local.rds_enabled ? 1 : 0

  length  = 48
  special = false
}

resource "random_password" "metamigo_authenticator" {
  count = local.rds_enabled ? 1 : 0

  length  = 48
  special = false
}

resource "random_password" "rds_superuser" {
  count = local.rds_enabled ? 1 : 0

  length  = 48
  special = false
}

resource "random_password" "zammad" {
  count = local.rds_enabled ? 1 : 0

  length  = 48
  special = false
}

module "rds" {
  source  = "cloudposse/rds/aws"
  version = "0.40.0"

  count = local.rds_enabled ? 1 : 0

  engine               = "postgres"
  instance_class       = local.rds_instance_type
  engine_version       = "16.3"
  major_engine_version = "16"
  db_parameter_group   = "postgres16"
  allocated_storage    = local.rds_allocated_disk_gb
  database_port        = 5432

  db_parameter = [
    { name = "rds.force_ssl", value = "0", apply_method = "immediate" }
  ]

  kms_key_arn = module.kms_key.key_arn

  deletion_protection         = (module.this.stage == "prod")
  apply_immediately           = (module.this.stage != "prod")
  skip_final_snapshot         = (module.this.stage != "prod")
  allow_major_version_upgrade = false
  backup_retention_period     = 30

  vpc_id = module.vpc.vpc_id
  subnet_ids = [
    module.dynamic_subnet[0].private_subnet_ids[0],
    module.dummy_subnet[0].private_subnet_ids[0],
  ]

  database_name     = "cdrlink"
  database_user     = "cdrlink"
  database_password = random_password.rds_superuser[0].result

  security_group_ids = [module.ec2_security_group[0].id]

  context    = module.this.context
  attributes = ["rds"]
}
