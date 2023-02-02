variable "archive_account_id" {
  default     = null
  type        = string
  description = <<EOT
    The AWS account ID of an account that should have access to the deployment's KMS key to facilitate archiving the
    deployment at the end of its lifecycle.
  EOT
}

variable "ebs_volume_disk_allocation_gb" {
  default     = null
  type        = number
  description = <<EOT
    The amount of storage to allocate for the EBS volume mounted at /var/lib/cdr inside the EC2 instance. If left
    unset, 10 GB will be allocated.
  EOT
}

variable "ec2_disk_allocation_gb" {
  default     = null
  type        = number
  description = <<EOT
    The amount of storage to allocate for the EC2 instance. If left unset, the amount allocated will depend on the stage
    of the deployment. If the stage variable is set to "prod", 100 GB will be allocated, otherwise only 40 GB will be
    allocated.
  EOT
}

variable "ec2_instance_type" {
  default     = null
  type        = string
  description = <<EOT
    The instance class for the EC2 instance. If left unset, the instance class will depend on the stage
    of the deployment. If the stage variable is set to "prod", t3.large will be use, otherwise only t3.medium.
  EOT
}

variable "es_enabled" {
  default     = true
  type        = bool
  description = <<EOT
    If set to false, no Elasticsearch resources will be created. This option may be used to reduce costs, with either
    the Elasticsearch server running within the Docker Compose stack on the EC2 instance at the expense of performance
    and reliability, or forgoing Elasticsearch entirely at the expense of full text search within Zammad.
  EOT
}

variable "es_allocated_disk_gb" {
  default     = null
  type        = number
  description = <<EOT
    The amount of storage to allocate for the Elasticsearch domain. If left unset, 10 GB will be allocated.
  EOT
}

variable "es_instance_type" {
  default = null
  type    = string
}

variable "rds_enabled" {
  default     = true
  type        = bool
  description = <<EOT
    If set to false, no RDS related resources will be created. This option may be used to reduce costs at the expense
    of reliability with the PostgreSQL server running in the Docker Compose stack in the EC2 instance.
  EOT
}

variable "rds_allocated_disk_gb" {
  default     = null
  type        = number
  description = "The amount of storage to allocate for the RDS instance. If left unset, 10 GB will be allocated."
}

variable "rds_instance_type" {
  default     = null
  type        = string
  description = "The instance class of the PostgreSQL RDS instance to deploy. If left unset, db.t3.micro will be used."
}
