resource "aws_lambda_function" "this" {
  depends_on = [
    aws_s3_object.this
  ]

  function_name = var.lambda_name
  role = aws_iam_role.this.arn
  runtime = "python3.9"

  timeout = 10
  memory_size = 128

  s3_bucket = aws_s3_object.this.bucket
  s3_key = aws_s3_object.this.key
  source_code_hash = filesha256("${local.lambda_code_file_path}/${var.python_class_name}.py")

  environment {
    variables = var.env_vars
  }

  handler = "${var.python_class_name}.lambda_handler"
}

resource "aws_lambda_event_source_mapping" "this" {
  event_source_arn = var.sqs_arn
  function_name    = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromSqs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "sqs.amazonaws.com"
  source_arn    = var.sqs_arn
}

resource "aws_lambda_function_event_invoke_config" "this" {
  function_name                = aws_lambda_function.this.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 1
}