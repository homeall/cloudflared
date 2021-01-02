[![cloudflared](https://github.com/homeall/cloudflared/workflows/CI/badge.svg)](https://github.com/homeall/cloudflared/actions) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Docker image with [cloudflared](https://github.com/cloudflare/cloudflared) for *DNS over HTTPS*

It is useful for setting up together with [PiHole](https://hub.docker.com/r/pihole/pihole).

### Default Settings

It will come with the following upstreams *in this order*:
1. 1.1.1.3
2. security.cloudflare-dns.com
3. 1.1.1.2
4. 1.0.0.2

The default port is **54**.

### Docker run command: 

```docker run -d --name cloudflare -p "54:54" homeall/cloudflared:latest```

```INFO[2021-01-01T20:03:37Z] Adding DNS upstream - url: https://1.1.1.3/dns-query
INFO[2021-01-01T20:03:37Z] Adding DNS upstream - url: https://security.cloudflare-dns.com/dns-query
INFO[2021-01-01T20:03:37Z] Adding DNS upstream - url: https://1.1.1.2/dns-query
INFO[2021-01-01T20:03:37Z] Adding DNS upstream - url: https://1.0.0.2/dns-query
INFO[2021-01-01T20:03:37Z] Starting metrics server on 127.0.0.1:8080/metrics
INFO[2021-01-01T20:03:37Z] Starting DNS over HTTPS proxy server on: dns://0.0.0.0:54
```
### Custom upstreams and custom port number:  

You can run change first two upstreams **DNS1** and **DNS2** and *port number*.

You can run:

```docker run -d --name cloudflared -p "5353:5353" -e "DNS1=8.8.8.8" -e "DNS2=1.1.1.1" -e "PORT=5353" homeall/cloudflared:latest```

Output:

```INFO[2021-01-01T20:08:36Z] Starting metrics server on 127.0.0.1:8080/metrics
INFO[2021-01-01T20:08:36Z] Adding DNS upstream - url: https://8.8.8.8/dns-query
INFO[2021-01-01T20:08:36Z] Adding DNS upstream - url: https://1.1.1.1/dns-query
INFO[2021-01-01T20:08:36Z] Adding DNS upstream - url: https://1.1.1.2/dns-query
INFO[2021-01-01T20:08:36Z] Adding DNS upstream - url: https://1.0.0.2/dns-query
INFO[2021-01-01T20:08:36Z] Starting DNS over HTTPS proxy server on: dns://0.0.0.0:5353
```

## Set up together with [PiHole](https://hub.docker.com/r/pihole/pihole)

[docker-compose.yml](https://docs.docker.com/compose/):

```
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    hostname: pihole
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "80:80/tcp"
    environment:
      TZ: 'Europe/London'
      WEBPASSWORD: 'admin'
      DNS1: '127.0.0.1#54'
      DNS2: 'no'
    volumes:
      - './etc-pihole/:/etc/pihole/'
    cap_add:
      - NET_ADMIN
    restart: unless-stopped

  cloudflare:
    restart: unless-stopped
    container_name: cloudflare
    image: homeall/cloudflared:latest
    links:
      - pihole
    ports:
      - "54:54/tcp"
      - "54:54/udp"
 
 ## Licence

Distributed under the MIT license
