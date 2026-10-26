variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
}

variable "tags" {
  description = "Tags applied to s3 resources"
  type        = map(string)
  default     = {}
}