#!/usr/bin/env bash

BACKUP_SCHEDULE="${BACKUP_SCHEDULE:-0 * * * *}"
COMPRESSION_ALGORITHM="${COMPRESSION_ALGORITHM:-gzip}"

mkdir -p /minecraft/backup

(crontab -l 2>/dev/null; echo "${BACKUP_SCHEDULE} /usr/bin/minecraft-backup -i /minecraft/world -o /minecraft/backup -w RCON -s 127.0.0.1:$RCON_PORT:$RCON_PASSWORD -a \"${COMPRESSION_ALGORITHM}\" -c >> /var/log/minecraft-backup.log 2>&1") | crontab -

cron -f