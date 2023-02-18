resource "aws_sqs_queue" "this" {
  name = var.queue_name
  sqs_managed_sse_enabled = false
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id
  policy    = jsonencode({
    Id = "sqspolicy"
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          Service = "events.amazonaws.com"
        }
        Effect = "Allow"
        Action = "sqs:SendMessage"
        Resource = aws_sqs_queue.this.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn": var.eventbridge_rule_arn
          }
        }
      },
    ]
  })
}