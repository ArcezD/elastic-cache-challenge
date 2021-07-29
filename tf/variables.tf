variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "ec2_key_name" {
  description = "AWS EC2 key pair name"
  type        = string
}

variable "rds_instance_identifier" {
  description = "AWS rds instance identifier"
  type        = string
}

variable "rds_instance_db_name" {
  description = "AWS rds instance db name"
  type        = string
}

variable "rds_instance_db_username" {
  description = "AWS rds instance db username"
  type        = string
}

variable "tags" {
  description = "AWS resources"
  type        = map(any)
}