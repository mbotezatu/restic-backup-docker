#!/bin/sh

set -eu

RESTIC_INIT_ARGS="${RESTIC_INIT_ARGS:-}"

init_restic_repo() {
    if restic cat config >/dev/null 2>&1; then
        printf "Restic repository already initialized.\n"
        return 0
    fi

    printf "Initializing restic repository.\n"
    (
        set -f
        set -- restic init
        if [ -n "$RESTIC_INIT_ARGS" ]; then
            # shellcheck disable=SC2086
            set -- "$@" ${RESTIC_INIT_ARGS}
        fi
        "$@"
    )
}

create_cron_config() {
    printf "Creating cron configuration.\n"
    mkdir -p /etc/supercronic
    if [ ! -f /etc/supercronic/crontab ]; then
        touch /etc/supercronic/crontab
    fi
}

init_restic_repo
create_cron_config

printf "Starting supercronic.\n"
exec supercronic /etc/supercronic/crontab "$@"
