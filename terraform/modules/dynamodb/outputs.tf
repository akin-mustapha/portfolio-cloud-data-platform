output "name" {
  description = "The name of the dynamodb name"
  value       = aws_dynamodb_table.this.name
}

output "arn" {
  description = "The name of the dynamodb name"
  value       = aws_dynamodb_table.this.arn
}