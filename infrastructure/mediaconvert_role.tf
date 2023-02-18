resource "aws_iam_role" "mediaconvert_audio_extractor" {
  name = "mediaconvert-audio-extractor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowMediaConvertService"
        Principal = {
          Service = "mediaconvert.amazonaws.com"
        }
        Effect: "Allow",
        Action: "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mediaconvert_audio_extractor" {
  policy_arn = aws_iam_policy.mediaconvert_audio_extraction.arn
  role = aws_iam_role.mediaconvert_audio_extractor.name
}

resource "aws_iam_policy" "mediaconvert_audio_extraction" {
  name = aws_iam_role.mediaconvert_audio_extractor.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowAccessToReadVideo"
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
        ]
        Resource = [
          "${aws_s3_bucket.data.arn}/video/*"
        ]
      },
      {
        Sid = "AllowAccessToReadAndWriteAudio"
        Effect = "Allow"
        Action = [
          "s3:PutObject*",
        ],
        Resource = [
          "${aws_s3_bucket.data.arn}/audio/*",
        ]
      },
    ]
  })
}