provider "aws" {
  region = var.aws_region
}

// Storage

module "data_lake" {
  source      = "./modules/s3"
  bucket_name = "${var.project_name}-${var.environment}-data-lake"
}

// Secret Manager

module "t212_secret" {
  source      = "./modules/secret_manager"
  secret_name = "${var.environment}/${var.project_name}/trading-212"

}

// Schedule

module "schedule_europe_open" {
  source     = "./modules/event_bridge_schedule"
  name       = "${var.project_name}-${var.environment}-schedule-europe-open"
  group_name = "default"

  flexible_time_window = "OFF"

  schedule_expression          = "cron(20 8 * * ? *)"
  schedule_expression_timezone = "Europe/Dublin"

  // Need to update to step function
  target_arn      = module.lambda_ingestion.arn
  target_role_arn = module.iam_role_schedule.arn
  target_input    = "europe-open" 
}

module "schedule_midday" {
  source     = "./modules/event_bridge_schedule"
  name       = "${var.project_name}-${var.environment}-schedule-midday"
  group_name = "default"

  flexible_time_window = "OFF"

  schedule_expression          = "cron(20 13 * * ? *)"
  schedule_expression_timezone = "Europe/Dublin"

  // Need to update to step function
  target_arn      = module.lambda_ingestion.arn
  target_role_arn = module.iam_role_schedule.arn
  target_input    = "midday" 
}

module "schedule_us_close" {
  source     = "./modules/event_bridge_schedule"
  name       = "${var.project_name}-${var.environment}-schedule-us-close"
  group_name = "default"

  flexible_time_window = "OFF"

  schedule_expression          = "cron(30 16 * * ? *)"
  schedule_expression_timezone = "Europe/Dublin"
  
  // Need to update to step function
  target_arn      = module.lambda_ingestion.arn
  target_role_arn = module.iam_role_schedule.arn
  target_input    = "us-close" 
}

// Compute resources

module "lambda_ingestion" {
  source = "./modules/lambda_function"

  function_name = "${var.project_name}-${var.environment}-ingestion"
  source_file = "${path.root}/../src/pipeline/t212-data-ingestion.py"
  lambda_role_arn = module.iam_role_lambda.arn
  handler       = "t212-data-ingestion.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
  sns_alert_topic_arn = module.alerts.arn

}

module "lambda_transformation" {
  source = "./modules/lambda_function"

  function_name = "${var.project_name}-${var.environment}-transformation"
  source_file = "${path.root}/../src/pipeline/t212-data-transformation.py"
  lambda_role_arn = module.iam_role_lambda.arn
  handler       = "t212-data-transformation.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
  sns_alert_topic_arn = module.alerts.arn

}

module "lambda_processing" {
  source = "./modules/lambda_function"

  function_name       = "${var.project_name}-${var.environment}-processing"
  source_file         = "${path.root}/../src/pipeline/t212-data-processing.py"
  lambda_role_arn     = module.iam_role_lambda.arn
  handler             = "t212-data-processing.lambda_handler"
  runtime             = "python3.12"
  timeout             = 300
  memory_size         = 512
  sns_alert_topic_arn = module.alerts.arn

}

module "lambda_dca" {
  source = "./modules/lambda_function"

  function_name       = "${var.project_name}-${var.environment}-dca"
  source_file         = "${path.root}/../src/application/t212-dca.py"
  lambda_role_arn     = module.iam_role_lambda.arn
  handler             = "t212-data-processing.lambda_handler"
  runtime             = "python3.12"
  timeout             = 300
  memory_size         = 512
  sns_alert_topic_arn = module.alerts.arn
}

// Database

module "trade_log" {
  source       = "./modules/dynamodb"
  table_name   = "${var.project_name}-${var.environment}-trade-log"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attributes   = [
    {
      name = "id"
      type = "S"
    }
  ]
}

// Monitoring

// sns
module "alerts" {
  source           = "./modules/sns"
  sns_topic_name   = "${var.project_name}-${var.environment}-alerts"
  sns_alerts_email = "akinkunmimustapha1@gmail.com"
}

// cloud watch alarm
module "ingestion-errors" {
  source              = "./modules/cloud_watch_alarm"
  alarm_name          = "${var.project_name}-${var.environment}-ingestion-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Fires when ingestion has any invocation errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_ingestion.function_name
  }

  alarm_actions = [module.alerts.arn]
}

// IAM Role

module "iam_role_schedule" {
  source          = "./modules/iam_role"
  aws_account_id  = var.aws_account_id
  iam_role_name   = "${var.project_name}-${var.environment}-schedule-role"
  iam_policy_name = "${var.project_name}-${var.environment}-schedule-policy"

  assume_role_statements = [
    {
      sid = "AllowSchedulerAssumeRole"
      effect= "Allow"
      services = ["scheduler.amazonaws.com"]
      action = ["sts:AssumeRole"]
      source_account = var.aws_account_id
    }
  ]

  iam_policy_statements = [
    {
      "sid" =  "StateFunctions"
      "effect" =  "Allow"
      "action" =  [
          "states:StartExecution"
        ]
      "resource" :  [
          // todo - add state function arn
          "*"
        ]

    }
  ]
}

module "iam_role_lambda" {
  source = "./modules/iam_role"
  aws_account_id = var.aws_account_id
  iam_role_name   = "${var.project_name}-${var.environment}-lambda-role"
  iam_policy_name = "${var.project_name}-${var.environment}-lambda-policy"

  assume_role_statements = [
    {
      sid = "AllowLambdaAssumeRole"
      effect= "Allow"
      services = ["lambda.amazonaws.com"]
      action = ["sts:AssumeRole"]
      source_account = var.aws_account_id
    }
  ]
  
  iam_policy_statements = [
    {
      "sid" = "CloudWatchLogs"
      "effect" = "Allow"
      "action" = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      "resource" : [
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/*"
        ]

    },
    {
      "sid" = "Secrets"
      "effect" = "Allow"
      "action" = [
          "secretsmanager:GetSecretValue"
        ]
      "resource" : [
          module.t212_secret.arn,
          // todo - create module and replace
          "arn:aws:secretsmanager:eu-west-1:861580917950:secret:prod/financial/t212-dca-automation-UqUvlT"
        ]

    },
    {
      "sid" = "S3Bucket"
      "effect" = "Allow"
      "action" = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
      "resource" : [
          module.data_lake.arn
        ]

    },
    {
      "sid" = "S3Objects"
      "effect" = "Allow"
      "action" = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
      "resource" : [
          "${module.data_lake.arn}/*"
        ]

    },
    {
      "sid" = "Athena"
      "effect" = "Allow"
      "action" = [
          "athena:GetWorkGroup",
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StopQueryExecution",
          "athena:GetDataCatalog"
        ]
      "resource" : [
          "arn:aws:athena:${var.aws_region}:${var.aws_account_id}:workgroup/*",
          "arn:aws:athena:${var.aws_region}:${var.aws_account_id}:datacatalog/*"
        ]
    },
    {
      "sid" = "PublishFailureAlerts"
      "effect" = "Allow"
      "action" = ["sns:Publish"]
      "resource" : [module.alerts.arn]
    },
      {
        "sid"      = "DynamoDb"
        "effect"   = "Allow"
        "action"   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        "resource" = [
          module.trade_log.arn  # Or "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/trade_log"
        ]
      },
      {
        "sid"    = "SESAccess"
        "effect" = "Allow"
        "action" = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        "resource" = ["*"]
      }
  ]
}