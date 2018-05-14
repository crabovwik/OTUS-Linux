#!/bin/bash

WATCH_SERVICES=('docker.service' 'wow.service')

ADMIN_EMAILS=('crabovwik@yandex.ru')

LOCK='/var/tmp/my_own_watchdog.lock'

function watchdog_echo() {
    echo -e '[' `date '+%Y-%m-%d %H:%M:%S'` '] ' "$@"
}

function send_email() {
    local title=$1
    local body=$2
    local email=$3

    echo "$body" | mail -s "$title" $email
}

if [[ -f $LOCK ]]; then
    watchdog_echo 'Watchdog is already running!'
    exit 6
fi

watchdog_echo "[WATCHDOG]"

touch $LOCK
trap "rm -f '$LOCK'; exit $?" INT TERM EXIT

rm -f $LOCK
trap - INT TERM EXIT

for service in ${WATCH_SERVICES[@]}; do
    status=`systemctl | grep running | grep $service`
    if [[ -z $status  ]]; then
        watchdog_echo "$service is down!"
        watchdog_echo "\t" "Sending message to admins..."

        for admin_email in ${ADMIN_EMAILS[@]}; do
            is_send=$(send_email "$service is down" "$service is down, you should up it as fast as you can!" $admin_email)
            watchdog_echo "\t\t" "* sent to " $admin_email
        done
    else
        watchdog_echo "\t" "$service is working normally"
    fi
    watchdog_echo ""
done
