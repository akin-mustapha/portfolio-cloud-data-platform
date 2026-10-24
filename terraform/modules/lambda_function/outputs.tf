output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "arn" {
  description = "The arn of the Lambda function"
  value       = aws_lambda_function.this.arn
}