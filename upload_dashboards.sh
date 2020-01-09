#!/bin/bash
DASHBOARDS_DIR="dashboards"
CURL_ARGS=(-q -s --insecure -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -H "Accept: application/json")

# Prepare dashboards for uploading
for DASHBOARD in $(ls -1 $DASHBOARDS_DIR/*.json); do
    # Get dashboard folder name from dashboard json file
    FOLDER_NAME=$(jq -r .meta.folderTitle $DASHBOARD)

    # If folder name is General, set folder id to 0
    if [ "$FOLDER_NAME" = "General" ];then
        jq '. += {"FolderId": 0}' $DASHBOARD > $DASHBOARD.upload
    # If folder name is defined, get folder id
    elif [ ! "$FOLDER_NAME" = "null" ]; then
        # Get folder id by name
        FOLDER_ID=$(curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/search/?query=" | jq --arg FOLDER_NAME "$FOLDER_NAME" -r '.[] | select(.type == "dash-folder") | select(.title == $FOLDER_NAME) | .id')
        # Add folder id to dashboard and write to new file
        jq --argjson FOLDER_ID $FOLDER_ID '. += {"FolderId": $FOLDER_ID}' $DASHBOARD > $DASHBOARD.upload
    fi
done

# Upload dashboards
for DASHBOARD_UPLOAD in $(ls -1 $DASHBOARDS_DIR/*.upload); do
    curl -X POST "${CURL_ARGS[@]}" $GRAFANA_URL/api/dashboards/db --data "@$DASHBOARD_UPLOAD"
done
