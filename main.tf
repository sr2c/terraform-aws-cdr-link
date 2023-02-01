
locals {
  availability_zones = slice(data.aws_availability_zones.this.names, 0, 2)
}

data "aws_caller_identity" "this" {}
data "aws_availability_zones" "this" {
  state = "available"
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.0.0"

  ipv4_primary_cidr_block          = "10.30.0.0/16"
  assign_generated_ipv6_cidr_block = false

  context    = module.this.context
  attributes = ["vpc"]
}

module "dynamic_subnet" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.1.0"

  count = module.this.enabled ? 1 : 0

  availability_zones = [local.availability_zones[0]]
  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]
  ipv4_cidr_block    = ["10.30.0.0/17"]
  ipv6_enabled       = false

  metadata_http_endpoint_enabled = true
  metadata_http_tokens_required  = true

  context    = module.this.context
  attributes = ["vpc"]
}

module "dummy_subnet" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.1.0"

  count = module.this.enabled ? 1 : 0

  availability_zones = [local.availability_zones[1]]
  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]
  ipv4_cidr_block    = ["10.30.128.0/17"]
  ipv6_enabled       = false

  metadata_http_endpoint_enabled = false

  public_subnets_enabled = false
  nat_gateway_enabled    = false
  nat_instance_enabled   = false

  context    = module.this.context
  attributes = ["vpc"]
}

module "vpc_endpoints" {
  source  = "cloudposse/vpc/aws//modules/vpc-endpoints"
  version = "2.0.0"

  vpc_id = module.vpc.vpc_id

  interface_vpc_endpoints = {
    "ec2" = {
      name                = "ec2"
      security_group_ids  = [module.ec2_security_group[0].id]
      subnet_ids          = module.dynamic_subnet[0].private_subnet_ids
      policy              = null
      private_dns_enabled = false
    },
    "ssm" = {
      name                = "ssm"
      security_group_ids  = [module.ec2_security_group[0].id]
      subnet_ids          = module.dynamic_subnet[0].private_subnet_ids
      policy              = null
      private_dns_enabled = false
    },
    "ssmmessages" = {
      name                = "ssmmessages"
      security_group_ids  = [module.ec2_security_group[0].id]
      subnet_ids          = module.dynamic_subnet[0].private_subnet_ids
      policy              = null
      private_dns_enabled = false
    },
  }
}

data "aws_iam_policy_document" "kms" {
  # this allows the acccount specified by archive_account_id
  # to have read access to our KMS key

  # this first statement is the default iam key policy
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }

    actions = [
      "kms:*",
    ]

    resources = [
      "*"
    ]
  }

  # these following statements re conditionally applied when we have an archive
  # account id
  dynamic "statement" {
    for_each = var.archive_account_id == null ? [] : [var.archive_account_id]
    content {
      sid    = "AllowArchiveAccount"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${statement.value}:root"]
      }

      resources = [
        "*"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.archive_account_id == null ? [] : [var.archive_account_id]
    content {
      sid    = "AllowArchiveAccountAttachmentOfPersistentResources"
      effect = "Allow"
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ]

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${statement.value}:root"]
      }

      resources = [
        "*"
      ]

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = [true]
      }
    }
  }
}

module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.9.0"

  description             = "general purpose KMS key for this CDR Link deployment"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  alias                   = "alias/${module.this.id}"

  policy = data.aws_iam_policy_document.kms.json

  context    = module.this.context
  attributes = ["kms"]
}
