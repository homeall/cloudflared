FROM golang:alpine as gobuild

RUN apk add --no-cache git gcc build-base; \
    go get -v github.com/cloudflare/cloudflared/cmd/cloudflared

WORKDIR /go/src/github.com/cloudflare/cloudflared/cmd/cloudflared

RUN go build ./

FROM alpine

LABEL maintainer="HomeAll"

ENV DNS1=""
ENV DNS2=""
ENV PORT=""
ENV ADDRESS=""
ENV METRICS=127.0.0.1:8080

RUN adduser -S cloudflared; \
    apk add --no-cache ca-certificates bind-tools libcap; \
    rm -rf /var/cache/apk/*;

COPY --from=gobuild /go/src/github.com/cloudflare/cloudflared/cmd/cloudflared/cloudflared /usr/local/bin/cloudflared

RUN setcap CAP_NET_BIND_SERVICE+eip /usr/local/bin/cloudflared

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD nslookup -po=${PORT:-54} cloudflare.com 127.0.0.1 || exit 1

EXPOSE ${PORT:-54}/udp

EXPOSE ${PORT:-54}/tcp

USER cloudflared

CMD /usr/local/bin/cloudflared proxy-dns --address ${ADDRESS:-0.0.0.0} --port ${PORT:-54} --metrics ${METRICS} --upstream https://${DNS1:-1.1.1.3}/dns-query --upstream https://${DNS2:-security.cloudflare-dns.com}/dns-query --upstream https://1.1.1.2/dns-query
