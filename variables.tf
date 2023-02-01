variable "archive_account_id" {
  default = null
  type    = string
}

variable "ebs_volume_disk_allocation_gb" {
  default = "30"
  type    = string
}

variable "ec2_instance_type" {
  default     = null
  type        = string
  description = "The EC2 instance type to create. This is for the EC2 instance that will run the CDR Link applications."
}

variable "es_enabled" {
  default     = true
  type        = bool
  description = "The OpenSearch instance type to create. If left unspecified, "
}

variable "es_allocated_disk_gb" {
  default = null
  type    = string
}

variable "es_instance_type" {
  default = null
  type    = string
}

variable "rds_enabled" {
  default = true
  type    = bool
}

variable "rds_allocated_disk_gb" {
  default = null
  type    = string
}

variable "rds_instance_type" {
  default = null
  type    = string
}
