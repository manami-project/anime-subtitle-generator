module "mediaconvert_lambda" {
  source = "./modules/sqs_triggered_lambda"
  lambda_name = "mediaconvert-job-creation"
  s3_bucket_name = aws_s3_bucket.data.bucket
  sqs_arn = module.trigger_audio_extraction_queue.sqs_queue_arn
  python_class_name = "MediaConvertJobCreation"
  iam_policy_statements = [
    {
      Sid = "AllowMediaConvertJobCreation"
      Effect = "Allow"
      Action = [
        "mediaconvert:Get*",
        "mediaconvert:List*",
        "mediaconvert:Describe*",
        "mediaconvert:CreateJob",
      ]
      Resource = [
        "*",
      ]
    },
    {
      Sid = "AllowAccessToReadVideoFiles"
      Effect = "Allow"
      Action = [
        "s3:List*",
        "s3:Describe*",
        "s3:Get*",
      ]
      Resource = [
        aws_s3_bucket.data.arn,
        "${aws_s3_bucket.data.arn}/video/*",
      ]
    },
    {
      Sid = "AllowAccessToReadAndWriteAudio"
      Effect = "Allow"
      Action = [
        "s3:List*",
        "s3:Describe*",
        "s3:Get*",
        "s3:CreateObject*",
        "s3:PutObject*",
      ]
      Resource = [
        "${aws_s3_bucket.data.arn}/audio/*",
      ]
    },
    {
      Sid = "AllowAccessToPassRole"
      Effect = "Allow"
      Action = [
        "iam:PassRole",
      ]
      Resource = [
        aws_iam_role.mediaconvert_audio_extractor.arn
      ]
    },
  ]
  env_vars = {
    JOB_TEMPLATE_NAME = module.aws_mediaconvert_job_template.name
    JOB_ROLE_ARN = aws_iam_role.mediaconvert_audio_extractor.arn
  }
}

module "aws_mediaconvert_job_template" {
  source = "./modules/aws_mediaconvert_job_template"

  name = "mp3-audio-extraction"
  region = var.region
  s3_bucket_target_uri = "s3://${aws_s3_bucket.data.bucket}/audio/"
}