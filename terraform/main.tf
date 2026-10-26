provider "aws" {
  region = var.aws_region
}

// Glue

module "portfolio_database" {
  source = "./modules/glue_catalog_database"
  name   = "${var.project_name}-${var.environment}"
}

// Storage

module "data_lake" {
  source      = "./modules/s3"
  bucket_name = "${var.project_name}-${var.environment}-data-lake"
  tags        = local.common_tags
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
  target_arn      = module.orchesration.arn
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
  target_arn      = module.orchesration.arn
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
  target_arn      = module.orchesration.arn
  target_role_arn = module.iam_role_schedule.arn
  target_input    = "us-close"
}

// Compute resources

module "lambda_ingestion" {
  source = "./modules/lambda_function"

  function_name       = "${var.project_name}-${var.environment}-ingestion"
  source_file         = "${path.root}/../portfolio/t212_pipeline/data_ingestion.py"
  lambda_role_arn     = module.iam_role_lambda_ingestion.arn
  handler             = "data_ingestion.lambda_handler"
  runtime             = "python3.12"
  timeout             = 300
  memory_size         = 512
  sns_alert_topic_arn = null
  environment_variables = {
    ENVIRONMENT      = var.environment
    REGION_NAME      = var.aws_region
    S3_BUCKET        = module.data_lake.bucket_name
    T212_SECRET_NAME = module.t212_secret.secret_name
    LOG_LEVEL        = "INFO"
    T212_API_URL     = "https://live.trading212.com/api/v0"

  }
}

module "lambda_transformation" {
  source = "./modules/lambda_function"

  function_name   = "${var.project_name}-${var.environment}-transformation"
  source_file     = "${path.root}/../portfolio/t212_pipeline/data_transformation.py"
  lambda_role_arn = module.iam_role_lambda_transformation.arn
  handler         = "data_transformation.lambda_handler"
  runtime         = "python3.12"
  timeout         = 300
  memory_size     = 512
  layers = [
    "arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python312:13"
  ]
  sns_alert_topic_arn = null
  environment_variables = {
    ENVIRONMENT   = var.environment
    REGION_NAME   = var.aws_region
    S3_BUCKET     = module.data_lake.bucket_name
    GLUE_DATABASE = module.portfolio_database.name
    LOG_LEVEL     = "INFO"

  }

}

module "lambda_processing" {
  source = "./modules/lambda_function"

  function_name   = "${var.project_name}-${var.environment}-processing"
  source_file     = "${path.root}/../portfolio/t212_pipeline/data_processing.py"
  lambda_role_arn = module.iam_role_lambda_processing.arn
  handler         = "data_processing.lambda_handler"
  runtime         = "python3.12"
  timeout         = 300
  memory_size     = 512
  layers = [
    "arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python312:13"
  ]
  sns_alert_topic_arn = null
  environment_variables = {
    ENVIRONMENT   = var.environment
    REGION_NAME   = var.aws_region
    S3_BUCKET     = module.data_lake.bucket_name
    GLUE_DATABASE = module.portfolio_database.name
    LOG_LEVEL     = "INFO"

  }
}

module "lambda_dca" {
  source = "./modules/lambda_function"

  package_type = "Image"

  function_name         = "${var.project_name}-${var.environment}-dca"
  image_uri             = "${aws_ecr_repository.t212_automation_image.repository_url}:latest"
  lambda_role_arn       = module.iam_role_lambda_dca.arn
  handler               = "dca.lambda_handler"
  runtime               = "python3.12"
  timeout               = 300
  memory_size           = 512
  layers                = []
  enable_failure_alerts = true
  sns_alert_topic_arn   = module.alerts.arn
  environment_variables = {
    ENVIRONMENT        = var.environment
    REGION_NAME        = var.aws_region
    S3_BUCKET          = module.data_lake.bucket_name
    GLUE_DATABASE      = module.portfolio_database.name
    LOG_TABLE          = module.trade_log.name
    NOTIFICATION_EMAIL = "akinkunmimustapha1@gmail.com"
    T212_SECRET_NAME   = "prod/financial/t212-dca-automation"
    T212_URL           = "https://live.trading212.com/api/v0/"
    LOG_LEVEL          = "INFO"

  }
}

// Database

module "trade_log" {
  source       = "./modules/dynamodb"
  table_name   = "${var.project_name}-${var.environment}-trade-log"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attributes = [
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
      sid            = "AllowSchedulerAssumeRole"
      effect         = "Allow"
      services       = ["scheduler.amazonaws.com"]
      action         = ["sts:AssumeRole"]
      source_account = var.aws_account_id
    }
  ]

  iam_policy_statements = [
    {
      "sid"    = "StateFunctions"
      "effect" = "Allow"
      "action" = [
        "states:StartExecution"
      ]
      "resource" : [
        module.orchesration.arn
      ]

    }
  ]
}

module "iam_role_lambda_ingestion" {
  source          = "./modules/iam_role"
  aws_account_id  = var.aws_account_id
  iam_role_name   = "${var.project_name}-${var.environment}-lambda-ingestion-role"
  iam_policy_name = "${var.project_name}-${var.environment}-lambda-ingestion-policy"

  assume_role_statements = [
    {
      sid            = "AllowLambdaAssumeRole"
      effect         = "Allow"
      services       = ["lambda.amazonaws.com"]
      action         = ["sts:AssumeRole"]
      source_account = var.aws_account_id
    }
  ]

  iam_policy_statements = [
    {
      sid    = "WriteLambdaLogs"
      effect = "Allow"
      action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resource = [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/*:log-stream:*"
      ]
    },
    {
      "sid"    = "Secrets"
      "effect" = "Allow"
      "action" = [
        "secretsmanager:GetSecretValue"
      ]
      "resource" : [
        module.t212_secret.arn,
      ]

    },
    {
      "sid"    = "S3Bucket"
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
      "sid"    = "S3Objects"
      "effect" = "Allow"
      "action" = [
        "s3:GetObject",
        "s3:PutObject",
      ]
      "resource" : [
        "${module.data_lake.arn}/*"
      ]

    },
    {
      "sid"    = "PublishFailureAlerts"
      "effect" = "Allow"
      "action" = ["sns:Publish"]
      "resource" : [module.alerts.arn]
    }
  ]
}

module "iam_role_lambda_transformation" {
  source          = "./modules/iam_role"
  aws_account_id  = var.aws_account_id
  iam_role_name   = "${var.project_name}-${var.environment}-lambda-transformation-role"
  iam_policy_name = "${var.project_name}-${var.environment}-lambda-transformation-policy"

  assume_role_statements = [
    {
      sid            = "AllowLambdaAssumeRole"
      effect         = "Allow"
      services       = ["lambda.amazonaws.com"]
      action         = ["sts:AssumeRole"]
      source_account = var.aws_account_id
    }
  ]

  iam_policy_statements = [
    {
      sid    = "WriteLambdaLogs"
      effect = "Allow"
      action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resource = [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/*:log-stream:*"
      ]
    },
    # {
    #   "sid" = "Secrets"
    #   "effect" = "Allow"
    #   "action" = [
    #       "secretsmanager:GetSecretValue"
    #     ]
    #   "resource" : [
    #       module.t212_secret.arn,
    #       // todo - create module and replace
    #       "arn:aws:secretsmanager:eu-west-1:861580917950:secret:prod/financial/t212-dca-automation-UqUvlT"
    #     ]

    # },
    {
      "sid"    = "S3Bucket"
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
      "sid"    = "S3Objects"
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
      "sid"    = "Athena"
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
      "sid"    = "PublishFailureAlerts"
      "effect" = "Allow"
      "action" = ["sns:Publish"]
      "resource" : [module.alerts.arn]
    },
    {
      "sid"    = "Glue"
      "effect" = "Allow"
      "action" = [
        "glue:GetDatabase",
        "glue:GetTable",
        "glue:GetTables",
        "glue:CreateTable",
        "glue:UpdateTable",
        "glue:GetPartitions",
        "glue:CreatePartition",
        "glue:BatchCreatePartition",
        "glue:BatchGetPartition",
        "glue:UpdatePartition",
      ]
      resource = [
        "arn:aws:glue:${var.aws_region}:${var.aws_account_id}:catalog",
        module.portfolio_database.arn,
        "arn:aws:glue:${var.aws_region}:${var.aws_account_id}:table/${module.portfolio_database.name}/*",
      ]

    }
  ]
}

module "iam_role_lambda_processing" {
  source          = "./modules/iam_role"
  aws_account_id  = var.aws_account_id
  iam_role_name   = "${var.project_name}-${var.environment}-lambda-processing-role"
  iam_policy_name = "${var.project_name}-${var.environment}-lambda-processing-policy"

  assume_role_statements = [
    {
      sid            = "AllowLambdaAssumeRole"
      effect         = "Allow"
      services       = ["lambda.amazonaws.com"]
      action         = ["sts:AssumeRole"]
      source_account = var.aws_account_id
    }
  ]

  iam_policy_statements = [
    {
      sid    = "WriteLambdaLogs"
      effect = "Allow"
      action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resource = [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/*:log-stream:*"
      ]
    },
    # {
    #   "sid" = "Secrets"
    #   "effect" = "Allow"
    #   "action" = [
    #       "secretsmanager:GetSecretValue"
    #     ]
    #   "resource" : [
    #       module.t212_secret.arn,
    #       // todo - create module and replace
    #       "arn:aws:secretsmanager:eu-west-1:861580917950:secret:prod/financial/t212-dca-automation-UqUvlT"
    #     ]

    # },
    {
      "sid"    = "S3Bucket"
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
      "sid"    = "S3Objects"
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
      "sid"    = "Athena"
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
      "sid"    = "PublishFailureAlerts"
      "effect" = "Allow"
      "action" = ["sns:Publish"]
      "resource" : [module.alerts.arn]
    },
    {
      "sid"    = "DynamoDb"
      "effect" = "Allow"
      "action" = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      "resource" = [
        module.trade_log.arn # Or "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/trade_log"
      ]
    },
    {
      "sid"    = "Glue"
      "effect" = "Allow"
      "action" = [
        "glue:GetDatabase",
        "glue:GetTable",
        "glue:GetTables",
        "glue:CreateTable",
        "glue:UpdateTable",
        "glue:GetPartitions",
        "glue:CreatePartition",
        "glue:BatchCreatePartition",
        "glue:BatchGetPartition",
        "glue:UpdatePartition",
        "glue:DeleteTable"
      ]
      resource = [
        "arn:aws:glue:${var.aws_region}:${var.aws_account_id}:catalog",
        module.portfolio_database.arn,
        "arn:aws:glue:${var.aws_region}:${var.aws_account_id}:table/${module.portfolio_database.name}/*",
      ]

    }
  ]
}

module "iam_role_lambda_dca" {
  source          = "./modules/iam_role"
  aws_account_id  = var.aws_account_id
  iam_role_name   = "${var.project_name}-${var.environment}-lambda-dca-role"
  iam_policy_name = "${var.project_name}-${var.environment}-lambda-dca-policy"

  assume_role_statements = [
    {
      sid            = "AllowLambdaAssumeRole"
      effect         = "Allow"
      services       = ["lambda.amazonaws.com"]
      action         = ["sts:AssumeRole"]
      source_account = var.aws_account_id
    }
  ]

  iam_policy_statements = [
    {
      sid    = "WriteLambdaLogs"
      effect = "Allow"
      action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resource = [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/*:log-stream:*"
      ]
    },
    {
      "sid"    = "Secrets"
      "effect" = "Allow"
      "action" = [
        "secretsmanager:GetSecretValue"
      ]
      "resource" : [
        // todo - create module and replace
        "arn:aws:secretsmanager:eu-west-1:861580917950:secret:prod/financial/t212-dca-automation-UqUvlT"
      ]

    },
    {
      "sid"    = "S3Bucket"
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
      "sid"    = "S3Objects"
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
      "sid"    = "Athena"
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
      "sid"    = "PublishFailureAlerts"
      "effect" = "Allow"
      "action" = ["sns:Publish"]
      "resource" : [module.alerts.arn]
    },
    {
      "sid"    = "DynamoDb"
      "effect" = "Allow"
      "action" = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      "resource" = [
        module.trade_log.arn # Or "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/trade_log"
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
    },
    {
      "sid"    = "LambdaECRImageRetrievalPolicy"
      "effect" = "Allow"
      "action" = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
      "resource" = ["*"]
    }
  ]
}

module "iam_role_step_function" {
  source          = "./modules/iam_role"
  aws_account_id  = var.aws_account_id
  iam_role_name   = "${var.project_name}-${var.environment}-step-function-role"
  iam_policy_name = "${var.project_name}-${var.environment}-step-function-policy"


  assume_role_statements = [{
    sid      = "AllowStepFunctionsAssumeRole"
    effect   = "Allow"
    services = ["states.amazonaws.com"]
    action   = ["sts:AssumeRole"]
  }]

  iam_policy_statements = [{
    sid    = "InvokePipelineLambdas"
    effect = "Allow"
    action = ["lambda:InvokeFunction"]
    resource = [
      "${module.lambda_ingestion.arn}:*",
      "${module.lambda_transformation.arn}:*",
      "${module.lambda_processing.arn}:*",
      "${module.lambda_dca.arn}:*"
    ]
    },
    {
      sid    = "SNS"
      effect = "Allow"
      action = ["SNS:Publish"]
      resource = [
        module.alerts.arn
      ]
    }
  ]
}

// Step Function

module "orchesration" {
  source = "./modules/step_function"

  name     = "${var.project_name}-${var.environment}-pipeline"
  role_arn = module.iam_role_step_function.arn

  asl = file(
    "${path.root}/step_functions/portolio-dev-orchestration.asl.json"
  )
}

module "silver_positions_table" {
  source = "./modules/glue_catalog_table"

  name          = "silver_t212_positions_test"
  database_name = module.portfolio_database.name
  location      = "s3://${module.data_lake.bucket_name}/data/trading-212/silver/positions/"

  schema = file("${path.root}/schemas/silver_t212_positions.json")
}

resource "aws_ecr_repository" "t212_automation_image" {
  name                 = "${var.project_name}-${var.environment}/t212-automation"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "t212_automation" {
  repository = aws_ecr_repository.t212_automation_image.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only one image tagged latest"

        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["latest"]
          countType      = "imageCountMoreThan"
          countNumber    = 1
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}
