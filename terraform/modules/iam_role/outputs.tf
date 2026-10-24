output "iam_role_name" {
  description = "The name of the iam role"
  value       = aws_iam_role.this.name
}

output "arn" {
  description = "The name of the iam role arn"
  value       = aws_iam_role.this.arn
}

output "policy_name" {
  description = "The arn of the iam policy name"
  value       = aws_iam_role_policy.this.name
}