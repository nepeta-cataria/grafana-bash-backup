#!/bin/bash
CURL_ARGS=(-q -s --insecure -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -H "Accept: application/json")

# Get all dashboards and folders uid and delete them
delete_dashboards(){
for ALL_UIDS in `curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/search/?query=" | jq -r '.[] | .uid'`; do
    curl -X DELETE "${CURL_ARGS[@]}" "$GRAFANA_URL/api/dashboards/uid/$ALL_UIDS" 
done
}

echo "--------------------------"
echo "$(tput bold)$(tput setaf 1) WARNING: $(tput sgr0)"
echo "$(tput bold)$(tput setaf 1) ALL dashboards and folders will be DELETED from $GRAFANA_URL $(tput sgr0)"
echo "--------------------------"
while true; do
    read -p "Answer 'YES, DELETE' to confirm, or any key to cancel: " confirm
    case $confirm in
        "YES, DELETE") delete_dashboards; break;;
        * ) echo "Canceled!"; exit;;
    esac
done
