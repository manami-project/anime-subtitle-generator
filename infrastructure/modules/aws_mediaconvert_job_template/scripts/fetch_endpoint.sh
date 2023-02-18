eval "$(jq -r '@sh "region=\(.region)"')"
aws mediaconvert describe-endpoints --region "${region}" --query "Endpoints[0]"