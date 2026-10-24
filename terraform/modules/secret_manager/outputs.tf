output "secret_name" {
  description = "The name of the secret"
  value        = aws_secretsmanager_secret.this.name
}

output "arn" {
  description = "The name of the secret"
  value        = aws_secretsmanager_secret.this.arn
}