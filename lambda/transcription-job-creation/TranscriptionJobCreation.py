import boto3
import json

TRANSCRIBE = boto3.client("transcribe")


def lambda_handler(event, context):
    print("Received event:", event)

    body_json = extract_original_message(event)

    s3_bucket_name = body_json["detail"]["bucket"]["name"]
    s3_object_key = body_json["detail"]["object"]["key"]
    filename = extract_filename(s3_object_key)
    input_uri = f"s3://{s3_bucket_name}/{s3_object_key}"

    create_transcription_job(filename, input_uri, s3_bucket_name)


def extract_original_message(event):
    print("Extracting original message")
    body_temp_replaced = str(event).replace('"', "<<>>")
    clean_event_json_string = body_temp_replaced.replace("'", '"')
    event_json = json.loads(clean_event_json_string)
    escaped_body_string = event_json["Records"][0]["body"]
    body_string = escaped_body_string.replace("<<>>", '"')
    body_json = json.loads(body_string)
    return body_json


def extract_filename(key):
    split = key.split("/")
    split_size = len(split)

    if split_size == 0:
        index = 0
    else:
        index = split_size-1

    return split[index]


def create_transcription_job(filename, input_uri, s3_bucket_name):
    print(f"creating job for [{input_uri}]")
    try:
        TRANSCRIBE.start_transcription_job(
            TranscriptionJobName=filename,
            Media={
                "MediaFileUri": input_uri
            },
            MediaFormat="mp3",
            LanguageCode="ja-JP",
            OutputBucketName=s3_bucket_name,
            OutputKey=f"transcriptions/{filename}",
            Subtitles={
                "Formats": [
                    "srt"
                ]
            },
        )
    except TRANSCRIBE.exceptions.ConflictException:
        print(f"Ignoring job creation for [{input_uri}], because a job with this name already exists.")
