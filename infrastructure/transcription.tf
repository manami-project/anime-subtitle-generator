module "transcription_lambda" {
  source = "./modules/sqs_triggered_lambda"
  lambda_name = "transcription-job-creation"
  s3_bucket_name = aws_s3_bucket.data.bucket
  sqs_arn = module.trigger_transcription_queue.sqs_queue_arn
  python_class_name = "TranscriptionJobCreation"
  iam_policy_statements = [
    {
      Sid: "AllowTranscriptionJobCreation",
      Effect: "Allow",
      Action: [
        "transcribe:Get*",
        "transcribe:Describe*",
        "transcribe:List*",
        "transcribe:StartTranscriptionJob",
      ],
      Resource: [
        "*",
      ]
    },
    {
      Sid: "AllowAccessToReadAudioFiles",
      Effect: "Allow",
      Action: [
        "s3:List*",
        "s3:Describe*",
        "s3:Get*",
      ],
      Resource: [
        aws_s3_bucket.data.arn,
        "${aws_s3_bucket.data.arn}/audio/*",
      ]
    },
    {
      Sid: "AllowAccessToReadAndWriteTranscriptions",
      Effect: "Allow",
      Action: [
        "s3:List*",
        "s3:Describe*",
        "s3:Get*",
        "s3:CreateObject*",
        "s3:PutObject*",
      ],
      Resource: [
        "${aws_s3_bucket.data.arn}/transcriptions/*",
      ]
    },
  ]
}