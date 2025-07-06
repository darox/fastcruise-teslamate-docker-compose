#!/bin/sh

# Set output file (with timestamp for uniqueness)
BACKUP_DIR="./backups"
BACKUP_FILE="$BACKUP_DIR/teslamate_$(date +%Y%m%d_%H%M%S).bck"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

echo "Starting backup to $BACKUP_FILE..."

# Run the backup
docker compose exec -T database pg_dump -U teslamate teslamate > "$BACKUP_FILE"
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "Backup successful: $BACKUP_FILE"
else
  echo "Backup failed with exit code $EXIT_CODE"
  exit $EXIT_CODE
fi

