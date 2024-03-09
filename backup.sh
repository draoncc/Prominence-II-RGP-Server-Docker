#!/usr/bin/env bash

(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/minecraft-backup -i /minecraft/world -o /minecraft/backup -w RCON -s 127.0.0.1:$RCON_PORT:$RCON_PASSWORD >> /var/log/minecraft-backup.log 2>&1") | crontab -

cron -f