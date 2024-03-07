# Stage 1: Download the correct cloudflared binary based on the target platform
FROM alpine AS downloader

ARG TARGETPLATFORM
ARG CLOUDFLARED_VERSION=

# Use a case statement to determine the correct binary to download based on the target platform
RUN case "${TARGETPLATFORM}" in \
    "linux/amd64") \
      CLOUDFLARED_BINARY_URL="https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-amd64" \
      ;; \
    "linux/arm/v6"|"linux/arm/v7") \
      CLOUDFLARED_BINARY_URL="https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-arm" \
      ;; \
    "linux/arm64") \
      CLOUDFLARED_BINARY_URL="https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-arm64" \
      ;; \
    *) echo "Unsupported platform: ${TARGETPLATFORM}"; exit 1 ;; \
    esac && \
    wget -O /cloudflared "${CLOUDFLARED_BINARY_URL}" && \
    chmod +x /cloudflared

# Stage 2: Setup the runtime environment
FROM alpine

# Copy environment variables and argument declarations if necessary

RUN apk add --no-cache ca-certificates tzdata && \
    adduser -S cloudflared

# Copy the cloudflared binary from the downloader stage
COPY --from=downloader /cloudflared /usr/local/bin/cloudflared

# Setup capability to allow cloudflared to bind to privileged ports
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/cloudflared

USER cloudflared

# Default configuration for cloudflared
ENV DNS1="1.1.1.3"
ENV DNS2="security.cloudflare-dns.com"
ENV PORT="54"
ENV ADDRESS="0.0.0.0"
ENV METRICS="127.0.0.1:8080"
ENV MAX_UPSTREAM_CONNS="0"

EXPOSE ${PORT}/udp
EXPOSE ${PORT}/tcp

CMD ["/usr/local/bin/cloudflared", "proxy-dns", \
    "--address", "${ADDRESS}", \
    "--port", "${PORT}", \
    "--metrics", "${METRICS}", \
    "--upstream", "https://${DNS1}/dns-query", \
    "--upstream", "https://${DNS2}/dns-query", \
    "--upstream", "https://1.1.1.2/dns-query", \
    "--max-upstream-conns", "${MAX_UPSTREAM_CONNS}"]
