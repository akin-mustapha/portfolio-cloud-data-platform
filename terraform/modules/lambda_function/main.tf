
data "archive_file" "this" {
  type             = "zip"
  source_file      = var.source_file
  output_path      = "${path.root}/build/${var.function_name}.zip"
  output_file_mode = "0644"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.lambda_role_arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  timeout       = var.timeout
  memory_size   = var.memory_size
}

# Failure Destination Alerting for DCA Lambda
resource "aws_lambda_function_event_invoke_config" "this" {
  count = var.sns_alert_topic_arn == null ? 0 : 1

  function_name = aws_lambda_function.this.function_name

  destination_config {
    on_failure {
      destination = var.sns_alert_topic_arn
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 30

  tags = var.tags
}