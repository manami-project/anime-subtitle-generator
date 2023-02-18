resource "aws_iam_role" "this" {
  name = "${var.lambda_name}-lambda-executor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowLambdaService"
        Principal = {
          Service = "lambda.amazonaws.com",
        },
        Effect = "Allow"
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role = aws_iam_role.this.name
}

resource "aws_iam_policy" "this" {
  name = aws_iam_role.this.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid = "AllowLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          aws_cloudwatch_log_group.this.arn,
          "${aws_cloudwatch_log_group.this.arn}:*",
        ]
      },
      {
        Sid = "AllowMessageRetrievalFromQueue"
        Effect = "Allow"
        Action = [
          "sqs:List*",
          "sqs:Get*",
          "sqs:ReceiveMessage",
          "sqs:PurgeQueue",
          "sqs:DeleteMessage",
        ]
        Resource = [
          var.sqs_arn
        ]
      },
    ],
    var.iam_policy_statements)
  })
}