import boto3
import json

TRANSLATE = boto3.client("translate")
S3 = boto3.client("s3")


def lambda_handler(event, context):
    print("Received event:", event)

    body_json = extract_original_message(event)

    s3_bucket_name = body_json["detail"]["bucket"]["name"]
    s3_object_key = body_json["detail"]["object"]["key"]

    if not s3_object_key.endswith(".srt"):
        print(f"Skipped [{s3_object_key}], because it's not a srt file.")
        return

    file_content = read_file_from_s3(s3_bucket_name, s3_object_key)
    translation = translate_srt_file(file_content)

    original_filename = filename_without_suffix(s3_object_key)
    original_filename_without_suffix = filename_without_suffix(original_filename)
    s3_key = "translations/{filename}".format(filename=original_filename_without_suffix)
    write_file_to_s3(s3_bucket_name, s3_key, translation)


def extract_original_message(event):
    body_temp_replaced = str(event).replace('"', "<<>>")
    clean_event_json_string = body_temp_replaced.replace("'", '"')
    event_json = json.loads(clean_event_json_string)
    escaped_body_string = event_json["Records"][0]["body"]
    body_string = escaped_body_string.replace("<<>>", '"')
    body_json = json.loads(body_string)
    return body_json


def read_file_from_s3(s3_bucket_name, s3_object_key):
    print(f"Reading file: bucket={s3_bucket_name} key={s3_object_key}")
    return S3.get_object(Bucket=s3_bucket_name, Key=s3_object_key)["Body"].read().decode("utf-8")


def translate_srt_file(file_content):
    print("Splitting file")
    caption_list = file_content.split("\n\n")

    print("Translating text")
    number_of_captions = len(caption_list)
    for index in range(0, number_of_captions):
        print(f"Translating {index} of {number_of_captions}")
        current_caption = caption_list[index].split("\n")
        response = TRANSLATE.translate_text(
            Text=current_caption[2],
            SourceLanguageCode="ja",
            TargetLanguageCode="en"
        )
        translated_line = str(response["TranslatedText"])
        current_caption[2] = translated_line
        caption_list[index] = "\n".join(current_caption)
    translation = "\n\n".join(caption_list)
    return translation


def write_file_to_s3(s3_bucket_name, s3_object_key, content):
    print(f"Writing translation: bucket={s3_bucket_name} key={s3_object_key}")
    S3.put_object(
        Bucket=s3_bucket_name,
        Key=s3_object_key,
        StorageClass="ONEZONE_IA",
        Body=bytearray(content, "utf-8")
    )


def filename_without_suffix(key):
    split = key.split("/")
    split_size = len(split)

    if split_size == 0:
        index = 0
    else:
        index = split_size-1

    return split[index]
