resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  lifecycle {
    prevent_destroy = true
  }
  tags   = var.tags

}