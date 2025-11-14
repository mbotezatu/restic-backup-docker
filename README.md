# Restic Backup Docker

## Introduction
Personal project I use to back up my homelab, packaged as an Alpine-based container image with:

- [restic](https://github.com/restic/restic) for deduplicated backups
- [rclone](https://github.com/rclone/rclone) for cloud storage transports
- [apprise](https://github.com/caronc/apprise) for multi-service notifications
- `sqlite` and `postgresql-client` for database-aware helpers

It leans on [supercronic](https://github.com/aptible/supercronic) so cron jobs stay visible and resilient inside containers.

## Quick start
1. Copy `examples/compose.yaml` into your stack and adjust the secrets and repository targets.
2. Drop your [restic](https://github.com/restic/restic) cron entries into `configs.restic-backup-cron`. They will be picked up from `/etc/supercronic/crontab` at runtime.
3. Mount the data you want to back up via `volumes` or `volumes_from` and restart the service.

```shell
docker compose -f examples/compose.yaml up --detach
```

The provided example backs up a Vaultwarden container, prunes old snapshots, and runs `restic check` nightly.

## Configuration
The entrypoint only reads a single optional variable:

| Variable | Description |
| --- | --- |
| `RESTIC_INIT_ARGS` | Extra flags passed to `restic init`. |

Every other variable you see in the compose example (`RESTIC_REPOSITORY`, `RESTIC_PASSWORD_FILE`, `RCLONE_CONFIG`, `APPRISE_URL`, etc.) belongs to [restic](https://github.com/restic/restic), [rclone](https://github.com/rclone/rclone), or [apprise](https://github.com/caronc/apprise). Set them exactly as those projects expect.

## Extending the image
Need additional tools (for example `mysqldump`)? Extend the image:

```dockerfile
FROM ghcr.io/mbotezatu/restic-backup:latest
RUN apk add --no-cache mysql-client
```

## License
Distributed under the terms of the MIT License. See `LICENSE` for details.