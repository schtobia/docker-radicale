FROM alpine:3.8

ARG COMMIT_ID
ARG BUILD_DATE
ARG VERSION=2.1.11
ARG UID=2999
ARG GID=2999

LABEL maintainer="Thomas Queste <tom@tomsquest.com>" \
      org.label-schema.name="Radicale Docker Image" \
      org.label-schema.description="Enhanced Docker image for Radicale, the CalDAV/CardDAV server" \
      org.label-schema.url="https://github.com/Kozea/Radicale" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-ref=$COMMIT_ID \
      org.label-schema.vcs-url="https://github.com/tomsquest/docker-radicale" \
      org.label-schema.schema-version="1.0"

RUN \
    apk update -U \
    && apk upgrade \
    && apk add --no-cache --virtual=build-dependencies \
        gcc \
        libffi-dev \
        musl-dev \
        python3-dev \
    && apk add --no-cache \
        curl \
        git \
        python3 \
        shadow \
        su-exec \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install radicale==$VERSION passlib[bcrypt] \
    && python3 -m pip install --upgrade git+https://github.com/Unrud/RadicaleInfCloud \
    && apk del --purge build-dependencies \
    && addgroup -g $GID radicale \
    && adduser -D -s /bin/false -H -u $UID -G radicale radicale \
    && mkdir -p /etc/radicale /var/lib/radicale \
    && chmod -R 770 /var/lib/radicale \
    && chown -R radicale:radicale /var/lib/radicale

COPY config /etc/radicale

HEALTHCHECK --interval=30s --retries=3 CMD curl --fail http://localhost:5232 || exit 1
VOLUME ["/var/lib/radicale"]
EXPOSE 5232

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["radicale", "--config", "/etc/radicale"]
