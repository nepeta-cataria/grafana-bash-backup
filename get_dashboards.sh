#!/bin/bash
DASHBOARDS_DIR="dashboards"
if [ ! -d $DASHBOARDS_DIR ]; then
  mkdir $DASHBOARDS_DIR
fi
CURL_ARGS=(-q -s --insecure -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -H "Accept: application/json")

# Get dashboards
for DASHBOARD_UID in `curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/search/?query=" | jq -r '.[] | select(.type == "dash-db") | .uid'`; do
    # Get dashboard name
    DASHBOARD_NAME=$(curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID" | jq -r .dashboard.title | tr " " -)
    # Get dashboard json withoud id and save it to json file
    curl "${CURL_ARGS[@]}" "$GRAFANA_URL/api/dashboards/uid/$DASHBOARD_UID" | jq '.| del(.dashboard.id)' > dashboards/$DASHBOARD_NAME.json
done
