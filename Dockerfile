# --- Build Stage ---
FROM alpine AS downloader

ARG CLOUDFLARED_BASE_URL="https://github.com/cloudflare/cloudflared/releases/download/"
ARG CLOUDFLARED_VERSION
ARG TARGETPLATFORM

RUN apk add --no-cache wget bind-tools ca-certificates tzdata

# Download the correct binary for the platform
RUN set -e; \
    case "${TARGETPLATFORM}" in \
        "linux/amd64") BINARY_URL="${CLOUDFLARED_BASE_URL}${CLOUDFLARED_VERSION}/cloudflared-linux-amd64" ;; \
        "linux/arm64") BINARY_URL="${CLOUDFLARED_BASE_URL}${CLOUDFLARED_VERSION}/cloudflared-linux-arm64" ;; \
        "Linux/arm"|"linux/arm/v7") BINARY_URL="${CLOUDFLARED_BASE_URL}${CLOUDFLARED_VERSION}/cloudflared-linux-arm" ;; \
        *) echo "Unsupported platform: ${TARGETPLATFORM}"; exit 1 ;; \
    esac && \
    wget -O /cloudflared "$BINARY_URL" && chmod +x /cloudflared
    
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# --- Runtime Stage ---
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=downloader /cloudflared /usr/local/bin/cloudflared
COPY --from=downloader /usr/bin/nslookup /usr/bin/nslookup
COPY --from=downloader /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=downloader /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=downloader /entrypoint.sh /entrypoint.sh

USER nonroot

ENV TZ=UTC

EXPOSE 54/udp 54/tcp

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s \
  CMD /usr/bin/nslookup -port=${PORT:-54} cloudflare.com 127.0.0.1 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
