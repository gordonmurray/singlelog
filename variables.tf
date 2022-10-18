variable "vpc_id" {
  type        = string
  description = "VPC ID to use"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID to use to find the AMI"
}

variable "aws_region" {
  type        = string
  description = "AWS region to use"
  default     = "us-east-1"
}

variable "subnet_id" {
  type        = string
  description = "AWS subnet to use"
}

variable "my_ip_address" {
  type = string
  description = "Your own IP address to enable SSH access"
}
