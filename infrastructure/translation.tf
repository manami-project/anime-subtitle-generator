module "translation_lambda" {
  source = "./modules/sqs_triggered_lambda"
  lambda_name = "translation"
  s3_bucket_name = aws_s3_bucket.data.bucket
  sqs_arn = module.trigger_translation_queue.sqs_queue_arn
  python_class_name = "Translation"
  iam_policy_statements = [
    {
      Sid: "AllowTranslation",
      Effect: "Allow",
      Action: [
        "translate:Get*",
        "translate:Describe*",
        "translate:List*",
        "translate:TranslateText",
      ],
      Resource: [
        "*",
      ]
    },
    {
      Sid: "AllowAccessToReadTranscriptions",
      Effect: "Allow",
      Action: [
        "s3:List*",
        "s3:Describe*",
        "s3:Get*",
      ],
      Resource: [
        aws_s3_bucket.data.arn,
        "${aws_s3_bucket.data.arn}/transcriptions/*",
      ]
    },
    {
      Sid: "AllowAccessToReadAndWriteTranslations",
      Effect: "Allow",
      Action: [
        "s3:List*",
        "s3:Describe*",
        "s3:Get*",
        "s3:CreateObject*",
        "s3:PutObject*",
      ],
      Resource: [
        "${aws_s3_bucket.data.arn}/translations/*",
      ]
    },
  ]
}