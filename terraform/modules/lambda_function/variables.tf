
variable "function_name" {
  type = string
}

variable "lambda_role_arn" {
  type = string
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

variable "package_type" {
  description = "Lambda deployment package type."
  type        = string
  default     = "Zip"

  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "package_type must be either Zip or Image."
  }
}

variable "source_file" {
  description = "Path to the Python source file for ZIP deployments."
  type        = string
  default     = null
  nullable    = true
}

variable "image_uri" {
  description = "ECR image URI for image-based Lambda deployments."
  type        = string
  default     = null
  nullable    = true
}

variable "runtime" {
  description = "Lambda runtime for ZIP deployments."
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Lambda handler for ZIP deployments."
  type        = string
  default     = "lambda_function.lambda_handler"
}
