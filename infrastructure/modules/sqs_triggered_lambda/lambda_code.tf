data "archive_file" "this" {
  type        = "zip"
  source_file = "${local.lambda_code_file_path}/${var.python_class_name}.py"
  output_path = "${local.lambda_code_file_path}/${var.python_class_name}.zip"
}

resource "aws_s3_object" "this" {
  key = "lambda-code/${var.python_class_name}.zip"
  bucket = var.s3_bucket_name
  source = data.archive_file.this.output_path
  storage_class = "ONEZONE_IA"
  etag = data.archive_file.this.output_base64sha256
}