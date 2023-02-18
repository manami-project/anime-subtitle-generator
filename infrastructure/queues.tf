module "trigger_transcription_queue" {
  source = "./modules/s3_triggered_queue"
  queue_name = "trigger-transcription"
  eventbridge_rule_arn = aws_cloudwatch_event_rule.capture_audio_file_creation.arn
}

module "trigger_audio_extraction_queue" {
  source = "./modules/s3_triggered_queue"
  queue_name = "trigger-audio-extraction"
  eventbridge_rule_arn = aws_cloudwatch_event_rule.capture_video_file_creation.arn
}

module "trigger_translation_queue" {
  source = "./modules/s3_triggered_queue"
  queue_name = "trigger-translation"
  eventbridge_rule_arn = aws_cloudwatch_event_rule.capture_transcription_file_creation.arn
}