#!/bin/bash
FOLDERS_DIR="folders"
if [ ! -d $FOLDERS_DIR ]; then
  mkdir $FOLDERS_DIR
fi
CURL_ARGS=(-q -s --insecure -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -H "Accept: application/json")

# Get folders
for FOLDER_UID in `curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/search/?query=" | jq -r '.[] | select(.type == "dash-folder") | .uid'`; do
    # Get folder name
    FOLDER_NAME=$(curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/dashboards/uid/$FOLDER_UID" | jq -r .dashboard.title | tr " " -)
    # Create folder json file
    curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/search/?query=" | jq --arg FOLDER_UID $FOLDER_UID '.[] | select(.type == "dash-folder") | select(.uid == $FOLDER_UID) | {uid: .uid, title: .title}' > folders/$FOLDER_NAME.json
done