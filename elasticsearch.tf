locals {
  es_enabled           = module.this.enabled && var.es_enabled
  es_allocated_disk_gb = coalesce(var.es_allocated_disk_gb, (module.this.stage == "prod") ? 30 : 10)
  es_instance_type     = coalesce(var.es_instance_type, (module.this.stage == "prod") ? "" : "t3.medium.elasticsearch")
}

module "elasticsearch_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context    = module.this.context
  attributes = ["search"]
}

module "elasticsearch" {
  source  = "cloudposse/elasticsearch/aws"
  version = "0.35.1"

  count = local.es_enabled ? 1 : 0

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = [module.dynamic_subnet[0].private_subnet_ids[0]]
  elasticsearch_version      = "7.9"
  instance_type              = local.es_instance_type
  instance_count             = 1
  availability_zone_count    = 2
  zone_awareness_enabled     = false
  warm_enabled               = false
  dedicated_master_enabled   = false
  ebs_volume_size            = local.es_allocated_disk_gb
  kibana_subdomain_name      = "kibana-es"
  encrypt_at_rest_enabled    = "true"
  security_groups            = [module.elasticsearch_inbound[0].id]
  encrypt_at_rest_kms_key_id = module.kms_key.key_id
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  context         = module.elasticsearch_label.context
  id_length_limit = 28 # Elasticsearch domains cannot be more than 28 characters
}

module "elasticsearch_inbound" {
  source  = "cloudposse/security-group/aws"
  version = "2.0.0"

  count = local.es_enabled ? 1 : 0

  vpc_id = module.vpc.vpc_id

  context    = module.elasticsearch_label.context
  attributes = ["inbound"]
}

resource "aws_elasticsearch_domain_policy" "default" {
  count = local.es_enabled ? 1 : 0

  domain_name     = module.elasticsearch[0].domain_name
  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "${module.elasticsearch[0].domain_arn}/*"
    }
  ]
}
POLICIES
}
