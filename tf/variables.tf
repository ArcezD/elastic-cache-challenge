variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "ec2_key_name" {
  description = "AWS EC2 key pair name"
  type        = string
}

variable "tags" {
  description = "AWS resources"
  type        = map(any)
}