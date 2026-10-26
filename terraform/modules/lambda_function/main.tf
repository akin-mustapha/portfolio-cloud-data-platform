
data "archive_file" "this" {
  count = var.package_type == "Zip" ? 1 : 0

  type             = "zip"
  source_file      = var.source_file
  output_path      = "${path.root}/build/${var.function_name}.zip"
  output_file_mode = "0644"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.lambda_role_arn

  package_type = var.package_type

  # ZIP configuration
  filename = var.package_type == "Zip" ? data.archive_file.this[0].output_path : null

  source_code_hash = var.package_type == "Zip" ? data.archive_file.this[0].output_base64sha256 : null

  runtime = var.package_type == "Zip" ? var.runtime : null
  handler = var.package_type == "Zip" ? var.handler : null

  # Container image configuration
  image_uri = var.package_type == "Image" ? var.image_uri : null

  timeout     = var.timeout
  memory_size = var.memory_size
  layers      = var.package_type == "Zip" ? var.layers : null

  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}

resource "aws_lambda_function_event_invoke_config" "this" {
  count = var.enable_failure_alerts ? 1 : 0

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
