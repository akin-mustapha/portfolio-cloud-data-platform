variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

variable "aws_account_id" {
  description = "The AWS account ID where resources will be deployed"
  type        = string
  default     = "861580917950"
}

variable "project_name" {
  type    = string
  default = "portfolio"
}

variable "environment" {
  type    = string
  default = "dev"
}
