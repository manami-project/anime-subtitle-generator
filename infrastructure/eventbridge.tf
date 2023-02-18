# https://docs.aws.amazon.com/transcribe/latest/dg/how-input.html
resource "aws_cloudwatch_event_rule" "capture_audio_file_creation" {
  name        = "capture-audio-object-creation"
  description = "Capture each audio file creation."

  event_pattern = jsonencode({
    source = [
      "aws.s3",
    ]
    detail-type = [
      "Object Created",
    ]
    detail = {
      bucket = {
        name = [
          aws_s3_bucket.data.bucket,
        ]
      }
      object = {
        key = [
          {
            prefix = "audio/"
          }
        ]
        "$or" = [
          {
            key = [
              {
                suffix = ".mp3"
              }
            ]
          },
          {
            key = [
              {
                suffix = ".mp4"
              }
            ]
          },
          {
            key = [
              {
                suffix = ".wav"
              }
            ]
          },
          {
            key = [
              {
                suffix = ".flac"
              }
            ]
          },
          {
            key = [
              {
                suffix = ".amr"
              }
            ]
          },
          {
            key = [
              {
                suffix = ".ogg"
              }
            ]
          },
          {
            key = [
              {
                suffix = ".webm"
              }
            ]
          },
        ]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "capture_audio_file_creation" {
  rule = aws_cloudwatch_event_rule.capture_audio_file_creation.name
  arn  = module.trigger_transcription_queue.sqs_queue_arn
}

resource "aws_cloudwatch_event_rule" "capture_video_file_creation" {
  name        = "capture-video-object-creation"
  description = "Capture each video file creation."

  event_pattern = jsonencode({
    source = [
      "aws.s3",
    ]
    detail-type = [
      "Object Created",
    ]
    detail = {
      bucket = {
        name = [
          aws_s3_bucket.data.bucket,
        ]
      }
      object = {
        key = [
          {
            suffix = ".mkv"
          }
        ]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "capture_video_file_creation" {
  rule = aws_cloudwatch_event_rule.capture_video_file_creation.name
  arn  = module.trigger_audio_extraction_queue.sqs_queue_arn
}

resource "aws_cloudwatch_event_rule" "capture_transcription_file_creation" {
  name        = "capture-transcription-object-creation"
  description = "Capture each transcription file creation."

  event_pattern = jsonencode({
    source = [
      "aws.s3",
    ]
    detail-type = [
      "Object Created",
    ]
    detail = {
      bucket = {
        name = [
          aws_s3_bucket.data.bucket,
        ]
      }
      object = {
        key = [
          {
            prefix = "transcriptions/" # it's not possible to filter by both prefix and suffix
          },
        ]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "capture_transcription_file_creation" {
  rule = aws_cloudwatch_event_rule.capture_transcription_file_creation.name
  arn  = module.trigger_translation_queue.sqs_queue_arn
}