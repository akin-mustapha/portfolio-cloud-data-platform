
variable "aws_account_id" {
  description = "AWS account ID used in the role trust policy"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM execution role"
  type        = string
}

variable "iam_policy_name" {
  description = "Name of the inline IAM policy"
  type        = string
}

variable "iam_policy_statements" {
  description = "Statements to include in the inline IAM policy"

  type = list(object({
    sid      = string
    effect   = string
    action   = list(string)
    resource = list(string)
  }))
}

variable "assume_role_statements" {
  type = list(object({
    sid            = string
    effect         = string
    services       = list(string)
    action         = list(string)
    source_account = optional(string)
  }))
}