FROM --platform=$BUILDPLATFORM alpine:3.23.0 AS build
ARG TARGETOS
ARG TARGETARCH

ARG SUPERCRONIC_VERSION=0.2.39 \
    RESTIC_VERSION=0.18.1 \
    RCLONE_VERSION=1.71.2 \
    APPRISE_VERSION=1.9.5

RUN apk add --no-cache curl bzip2 unzip python3 binutils

RUN mkdir /tmp/bin && \
    curl -fsSL https://github.com/aptible/supercronic/releases/download/v0.2.39/supercronic-${TARGETOS}-${TARGETARCH} -o /tmp/bin/supercronic && \
    curl -fsSL https://github.com/restic/restic/releases/download/v0.18.1/restic_0.18.1_${TARGETOS}_${TARGETARCH}.bz2 -o /tmp/bin/restic.bz2 && \
    bzip2 -d /tmp/bin/restic.bz2 && \
    curl -fsSL https://downloads.rclone.org/v1.71.2/rclone-v1.71.2-${TARGETOS}-${TARGETARCH}.zip -o /tmp/bin/rclone.zip && \
    unzip /tmp/bin/rclone.zip -d /tmp/bin/ && \
    mv /tmp/bin/rclone-*-${TARGETOS}-${TARGETARCH}/rclone /tmp/bin && \
    rm -rf /tmp/bin/rclone-* /tmp/bin/rclone.zip && \
    python -m venv /tmp/pyenv && \
    . /tmp/pyenv/bin/activate && \
    pip install --no-cache-dir apprise==${APPRISE_VERSION} pyinstaller && \
    pyinstaller --collect-all apprise --onefile --distpath /tmp/bin /tmp/pyenv/bin/apprise

FROM alpine:3.23.0 AS final

RUN apk add --no-cache sqlite postgresql-client tzdata

COPY --from=build --chmod=0555 /tmp/bin/* /usr/local/bin/
COPY --chmod=0555 scripts/entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
