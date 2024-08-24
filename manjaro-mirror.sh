#!/bin/bash

# This script should be a cronjob and should be run a few times a day. (example for /etc/crontab: "0  *  *  *  * root /usr/bin/manjaroreposync").
# However you can also move this script to "/etc/cron.hourly".
# To be an official Manjaro Linux mirror and to get access to our rsync server, you have to tell us your static ip of your synchronization server.
HOME="/srv/http"
DESTPATH="${HOME}/manjaro"
LOCKFILE=/tmp/rsync-manjaro.lock


echo "$(date) >> Start synchronization with ${SOURCE_MIRROR}"

synchronize() {
    rsync -rtlvH --delete-after --delay-updates --safe-links "${SOURCE_MIRROR}" "$DESTPATH"
}



if [ ! -e "$LOCKFILE" ]
then
    echo $$ >"$LOCKFILE"
    synchronize
else
    PID=$(cat "$LOCKFILE")
    if kill -0 "$PID" >&/dev/null
    then
        echo "Rsync - Synchronization still running"
        exit 0
    else
        echo $$ >"$LOCKFILE"
        echo "Warning: previous synchronization appears not to have finished correctly"
        synchronize
    fi
fi
echo "$(date) >> Synchronization with ${SOURCE_MIRROR} completed"
rm -f "$LOCKFILE"
