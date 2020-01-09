# Grafana Backup Scripts

This scripts can backup and restore dashboards with folders structure.

## Requirements
- curl
- jq

## Usage

Set grafana URL and API token

```
export GRAFANA_URL="http://grafana.example.com:3000"
export KEY="XXXXXXXXXX"
```

### Backup
- `get_folders.sh` - Backup folders as json files to ./folders directory.
- `get_dashboards.sh` - Backup dashboards as json files to ./dashboards directory.

### Restore
- `upload_folders.sh` - Upload folders. **Run this first!**
- `upload_dashboards.sh` - Upload dashboards and put them to apropriate folders.

### Delete all dashboards and folders
- `delete_all_dashboards.sh` - Delete all dashboards and folders. **Only for test purposes!**
