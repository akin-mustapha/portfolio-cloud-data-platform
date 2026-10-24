output "bucket_name" {
  description = "The name of the S3 bucket"
  value = aws_s3_bucket.this.bucket
}


output "arn" {
  description = "The arn of the S3 bucket"
  value = aws_s3_bucket.this.arn
}
