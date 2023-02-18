import boto3
import json
import os


JOB_TEMPLATE_NAME = os.environ["JOB_TEMPLATE_NAME"]
JOB_ROLE_ARN = os.environ["JOB_ROLE_ARN"]


def lambda_handler(event, context):
    print("Received event:", event)

    body_json = extract_original_message(event)

    s3_bucket_name = body_json["detail"]["bucket"]["name"]
    s3_object_key = body_json["detail"]["object"]["key"]
    input_uri = f"s3://{s3_bucket_name}/{s3_object_key}"

    create_mediaconvert_job(input_uri)


def extract_original_message(event):
    print("Extracting original message")
    body_temp_replaced = str(event).replace('"', "<<>>")
    clean_event_json_string = body_temp_replaced.replace("'", '"')
    event_json = json.loads(clean_event_json_string)
    escaped_body_string = event_json["Records"][0]["body"]
    body_string = escaped_body_string.replace("<<>>", '"')
    body_json = json.loads(body_string)
    return body_json


def fetch_endpoint():
    print("Fetching individual endpoint")
    response = boto3.client("mediaconvert").describe_endpoints()
    return response["Endpoints"][0]["Url"]


def create_mediaconvert_job(input_uri):
    print(f"creating job for [{input_uri}]")
    boto3.client("mediaconvert", endpoint_url=fetch_endpoint()).create_job(
        JobTemplate=JOB_TEMPLATE_NAME,
        Priority=0,
        Role=JOB_ROLE_ARN,
        AccelerationSettings={
            "Mode": "DISABLED"
        },
        HopDestinations=[],
        Settings={
            "TimecodeConfig": {
                "Source": "ZEROBASED"
            },
            "Inputs": [
                {
                    "AudioSelectors": {
                        "Audio Selector 1": {
                            "Tracks": [
                                1
                            ],
                            "DefaultSelection": "DEFAULT",
                            "SelectorType": "TRACK"
                        }
                    },
                    "TimecodeSource": "ZEROBASED",
                    "FileInput": input_uri
                }
            ]
        }
    )
