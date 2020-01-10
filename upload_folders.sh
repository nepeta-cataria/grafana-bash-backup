#!/bin/bash
FOLDERS_DIR="folders"
CURL_ARGS=(-q -s --insecure -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -H "Accept: application/json")

# Upload folders
for FOLDERS_UPLOAD in $(ls -1 $FOLDERS_DIR/*.json); do
    echo -e "\n\n$FOLDERS_UPLOAD:"
    curl -X POST "${CURL_ARGS[@]}" $GRAFANA_URL/api/folders --data "@$FOLDERS_UPLOAD"
done