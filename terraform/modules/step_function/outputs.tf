output "arn" {
  description = "ARN of the Step Function"
  value       = aws_sfn_state_machine.this.arn
}
