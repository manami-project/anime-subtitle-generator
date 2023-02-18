{
  "Description": "Extracts the first track as mp3",
  "Category": "extraction",
  "Name": "${template_name}",
  "Settings": {
    "TimecodeConfig": {
      "Source": "ZEROBASED"
    },
    "OutputGroups": [
      {
        "Name": "File Group",
        "Outputs": [
          {
            "ContainerSettings": {
              "Container": "RAW"
            },
            "AudioDescriptions": [
              {
                "AudioSourceName": "Audio Selector 1",
                "CodecSettings": {
                  "Codec": "MP3",
                  "Mp3Settings": {
                    "Bitrate": 296000,
                    "RateControlMode": "CBR",
                    "SampleRate": 48000
                  }
                }
              }
            ]
          }
        ],
        "OutputGroupSettings": {
          "Type": "FILE_GROUP_SETTINGS",
          "FileGroupSettings": {
            "Destination": "${s3_target_bucket_arn}"
          }
        }
      }
    ],
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
        "TimecodeSource": "ZEROBASED"
      }
    ]
  },
  "AccelerationSettings": {
    "Mode": "DISABLED"
  },
  "StatusUpdateInterval": "SECONDS_60",
  "Priority": 0,
  "HopDestinations": []
}