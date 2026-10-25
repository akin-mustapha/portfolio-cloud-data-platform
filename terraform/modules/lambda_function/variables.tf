
variable "function_name" {
  type = string
}

variable "source_file" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "tags" {
  description = "Tags applied to Lambda resources"
  type        = map(string)
  default     = {}
}

variable "enable_failure_alerts" {
  description = "Whether to configure an asynchronous failure destination."
  type        = bool
  default     = false
}

variable "sns_alert_topic_arn" {
  description = "SNS topic ARN for asynchronous Lambda failure notifications."
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Environment variables passed to the Lambda function."
  type        = map(string)
  default     = {}
}

variable "layers" {
  description = "Optional Lambda layer ARNs."
  type        = list(string)
  default     = []
}