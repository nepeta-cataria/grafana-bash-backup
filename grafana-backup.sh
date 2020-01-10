#!/bin/bash
FOLDERS_DIR="folders"
DASHBOARDS_DIR="dashboards"
CURL_ARGS=(-q -s --insecure -H "Authorization: Bearer $GRAFANA_TOKEN" -H "Content-Type: application/json" -H "Accept: application/json")


get_folders(){
    if [ ! -d $FOLDERS_DIR ]; then
        mkdir $FOLDERS_DIR
    fi
    # Get folders
    for FOLDER_UID in `curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/search/?query=" | jq -r '.[] | select(.type == "dash-folder") | .uid'`; do
        # Get folder name
        FOLDER_NAME=$(curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/dashboards/uid/$FOLDER_UID" | jq -r .dashboard.title | tr " " -)
        # Create folder json file
        curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/search/?query=" | jq --arg FOLDER_UID $FOLDER_UID '.[] | select(.type == "dash-folder") | select(.uid == $FOLDER_UID) | {uid: .uid, title: .title}' > folders/$FOLDER_NAME.json
    done
    echo -e "\nFolders download done.\n"
}

get_dashboards(){
    if [ ! -d $DASHBOARDS_DIR ]; then
        mkdir $DASHBOARDS_DIR
    fi
    # Get dashboards
    for DASHBOARD_UID in `curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/search/?query=" | jq -r '.[] | select(.type == "dash-db") | .uid'`; do
        # Get dashboard name
        DASHBOARD_NAME=$(curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID" | jq -r .dashboard.title | tr " " -)
        # Get dashboard json withoud id and save it to json file
        curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID" | jq '.| del(.dashboard.id)' > dashboards/$DASHBOARD_NAME.json
    done
    echo -e "\nDashboards download done.\n"
}

upload_folders(){
    # Upload folders
    for FOLDERS_UPLOAD in $(ls -1 $FOLDERS_DIR/*.json); do
        echo -e "\n\n$FOLDERS_UPLOAD:"
        curl -X POST "${CURL_ARGS[@]}" $GRAFANA_URL/api/folders --data "@$FOLDERS_UPLOAD"
    done
    echo -e "\nFolders upload done.\n"
}

upload_dashboards(){
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
        echo -e "\n\n$DASHBOARD_UPLOAD:"
        curl -X POST "${CURL_ARGS[@]}" $GRAFANA_URL/api/dashboards/db --data "@$DASHBOARD_UPLOAD"
    done
    echo -e "\nDashboards upload done.\n"
}


check_json(){
    for JSON_FILE in `find $DASHBOARDS_DIR $FOLDERS_DIR -type f -name "*.json"`; do
        jq -e . $JSON_FILE >/dev/null
        if [ ! $? = 0 ];then
            echo "ERROR: $JSON_FILE is not a valid json"
        fi
    done
}

delete_all_dashboards(){
    echo "--------------------------"
    echo "$(tput bold)$(tput setaf 1) WARNING: $(tput sgr0)"
    echo "$(tput bold)$(tput setaf 1) ALL dashboards and folders will be DELETED from $GRAFANA_URL $(tput sgr0)"
    echo "--------------------------"
    while true; do
        read -p "Answer 'YES, DELETE' to confirm, or any key to cancel: " confirm
        case $confirm in
            "YES, DELETE")
                # Get all dashboards and folders uid and delete them
                for ALL_UIDS in `curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/search/?query=" | jq -r '.[] | .uid'`; do
                    curl -X DELETE "${CURL_ARGS[@]}" "$GRAFANA_URL/api/dashboards/uid/$ALL_UIDS" 
                done
                exit
                ;;
            * ) echo "Canceled!"; exit;;
        esac
    done
}

show_help(){
cat << EOF
Usage:
--get           Backup all folders and dashboards and save it as json files
--check         Validate all downloaded json files
--upload        Restore all folders and dashboards to Grafana server
--delete-all    Delete all folders and dashboards from Grafana server
EOF
}

# Start script

if [ -z $GRAFANA_URL ]; then echo "GRAFANA_URL is not set!"; exit 1; fi
if [ -z $GRAFANA_TOKEN ]; then echo "GRAFANA_TOKEN is not set! $GRAFANA_URL"; exit 1; fi
if [ "$#" -eq 0 ]; then show_help; exit 1; fi

ACTION=$1
case $ACTION in
    --check) check_json; exit;;
    --get) get_folders; get_dashboards; exit;;
    --upload) upload_folders; upload_dashboards; exit;;
    --delete-all) delete_all_dashboards; exit;;
    *) show_help; exit;;
esac

