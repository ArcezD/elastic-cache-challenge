variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "ec2_instance_name" {
  description = "AWS EC2 instance name"
  type        = string
}
variable "ec2_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default = "t2.micro"
}

variable "ec2_key_name" {
  description = "AWS EC2 key pair name"
  type        = string
}

variable "rds_instance_identifier" {
  description = "AWS rds instance identifier"
  type        = string
}

variable "rds_instance_db_instance_class" {
  description = "AWS rds instance class"
  type        = string
  default =     "db.t2.micro"
}

variable "rds_instance_db_name" {
  description = "AWS rds instance db name"
  type        = string
}

variable "rds_instance_db_username" {
  description = "AWS rds instance db username"
  type        = string
}

variable "redis_cluster_name" {
  description = "AWS Elasticache redis cluster name"
  type        = string
}

variable "redis_cluster_node_type" {
  description = "AWS Elasticache redis cluster name"
  type        = string
  default = "cache.t2.micro"
}

variable "sql_initial_script_url" {
  description = "SQL Initial script url"
  type        = string
}

variable "tags" {
  description = "AWS resources tags"
  type        = map(any)
}