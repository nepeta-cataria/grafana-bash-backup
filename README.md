# Grafana Backup Scripts

This script can backup and restore dashboards with folders structure.

## Requirements
- curl
- jq

## Usage

**Set grafana URL and API token:**

```
export GRAFANA_URL="http://grafana.example.com:3000"
export GRAFANA_TOKEN="XXXXXXXXXX"
```

**Run script with arguments:**

```
Usage:
--get           Backup all folders and dashboards and save it as json files
--check         Validate all downloaded json files
--upload        Restore all folders and dashboards to Grafana server
--delete-all    Delete all folders and dashboards from Grafana server
```
