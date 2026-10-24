resource "aws_iam_role" "this" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      for statement in var.assume_role_statements : merge(
        {
          Sid    = statement.sid
          Effect = statement.effect

          Principal = {
            Service = statement.services
          }

          Action = statement.action
        },
        statement.source_account == null ? {} : {
          Condition = {
            StringEquals = {
              "aws:SourceAccount" = statement.source_account
            }
          }
        }
      )
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = var.iam_policy_name
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in var.iam_policy_statements : {
        Sid      = statement.sid
        Effect   = statement.effect
        Action   = statement.action
        Resource = statement.resource
      }
    ]
  })
}

# resource "aws_iam_role_policy_attachment" "this" {
#   role       = aws_iam_role.this.name
#   policy_arn = aws_iam_role_policy.this.arn
# }