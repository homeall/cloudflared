[![cloudflared](https://github.com/homeall/cloudflared/workflows/CI/badge.svg)](https://github.com/homeall/cloudflared/actions) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![pull](https://img.shields.io/docker/pulls/homeall/cloudflared)](https://img.shields.io/docker/pulls/homeall/cloudflared) [![pull](https://img.shields.io/docker/image-size/homeall/cloudflared)](https://img.shields.io/docker/image-size/homeall/cloudflared)

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
      </ul>
    </li>
    <li>
      <a href="#usage">Usage</a>
      <ul>
        <li><a href="#potentials-issues">Potentials issues</a></li>
      </ul>
       <ul>
        <li><a href="#testing">Testing</a></li>
      </ul>
       <ul>
        <li><a href="#pihole-and-dhcp-relay">PiHole and DHCP Relay</a></li>
      </ul>
    </li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>

# Docker image with [cloudflared](https://github.com/cloudflare/cloudflared) for *[DNS over HTTPS](https://www.cloudflare.com/en-gb/learning/dns/dns-over-tls/)*

It is useful for setting up together with [PiHole](https://github.com/pi-hole/pi-hole).

### Default Settings

It will come with the following upstreams *in this order*:
* :one: 1.1.1.3
* :two: security.cloudflare-dns.com
* :three: 1.1.1.2
* :four: 1.0.0.2

The default port is **54**.

Addres is *0.0.0.0*

:arrow_up: [Go on TOP](#about-the-project) :point_up:

### Docker run command: 

```docker run -d --name cloudflare -p "54:54" -p "54:54/udp" homeall/cloudflared:latest```

:arrow_down: Docker logs output:

```
INFO[2021-01-01T20:03:37Z] Adding DNS upstream - url: https://1.1.1.3/dns-query
INFO[2021-01-01T20:03:37Z] Adding DNS upstream - url: https://security.cloudflare-dns.com/dns-query
INFO[2021-01-01T20:03:37Z] Adding DNS upstream - url: https://1.1.1.2/dns-query
INFO[2021-01-01T20:03:37Z] Adding DNS upstream - url: https://1.0.0.2/dns-query
INFO[2021-01-01T20:03:37Z] Starting metrics server on 127.0.0.1:8080/metrics
INFO[2021-01-01T20:03:37Z] Starting DNS over HTTPS proxy server on: dns://0.0.0.0:54
```
:arrow_down: Simple tests:

```
❯ dig google.com @127.0.0.1 -p 54 +short
216.58.211.174
❯ dig google.com @127.0.0.1 +tcp -p 54 +short
216.58.211.174
```

:arrow_up: [Go on TOP](#about-the-project) :point_up:

### Custom upstreams and custom port number:  

:biohazard: You can run change first two upstreams **DNS1** and **DNS2** and *port number*.

:eight_pointed_black_star: You can run:

```docker run -d --name cloudflared -p "5353:5353" -p "5353:5353/udp" -e "DNS1=8.8.8.8" -e "DNS2=1.1.1.1" -e "PORT=5353" homeall/cloudflared:latest```

:arrow_down: Output result:

```
INFO[2021-01-01T20:08:36Z] Starting metrics server on 127.0.0.1:8080/metrics
INFO[2021-01-01T20:08:36Z] Adding DNS upstream - url: https://8.8.8.8/dns-query
INFO[2021-01-01T20:08:36Z] Adding DNS upstream - url: https://1.1.1.1/dns-query
INFO[2021-01-01T20:08:36Z] Adding DNS upstream - url: https://1.1.1.2/dns-query
INFO[2021-01-01T20:08:36Z] Adding DNS upstream - url: https://1.0.0.2/dns-query
INFO[2021-01-01T20:08:36Z] Starting DNS over HTTPS proxy server on: dns://0.0.0.0:5353
```

:arrow_up: [Go on TOP](#about-the-project) :point_up:

### Dualstack Ipv4/IPv6

:warning: You also can use:

`docker run --name cloudflared -d -p "54:54" -p "54:54/udp" -e "ADDRESS=::" homeall/cloudflared`

:arrow_down: Output result:

```
INFO[2021-01-02T14:38:53Z] Adding DNS upstream - url: https://1.1.1.3/dns-query
INFO[2021-01-02T14:38:53Z] Adding DNS upstream - url: https://security.cloudflare-dns.com/dns-query
INFO[2021-01-02T14:38:53Z] Adding DNS upstream - url: https://1.1.1.2/dns-query
INFO[2021-01-02T14:38:53Z] Adding DNS upstream - url: https://1.0.0.2/dns-query
INFO[2021-01-02T14:38:53Z] Starting metrics server on 127.0.0.1:8080/metrics
INFO[2021-01-02T14:38:53Z] Starting DNS over HTTPS proxy server on: dns://[::]:54
```
:arrow_down: Simple tests:

```
❯ dig google.com @::1 +tcp -p 54 +short
216.58.213.14
❯ dig google.com @::1 -p 54 +short
216.58.213.14
```
:arrow_up: [Go on TOP](#about-the-project) :point_up:

## Set up together with [PiHole](https://hub.docker.com/r/pihole/pihole)

:yin_yang: PiHole with **cloudflared** is a match in heaven :bangbang:

:arrow_down: Check out this [docker-compose.yml](https://docs.docker.com/compose/):

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
```

:arrow_up: [Go on TOP](#about-the-project) :point_up:

 <!-- LICENSE -->
 ### Licence

:newspaper_roll: Distributed under the MIT license. See [LICENSE](https://raw.githubusercontent.com/homeall/cloudflared/main/LICENSE) for more information.

:arrow_up: [Go on TOP](#about-the-project) :point_up:

<!-- CONTACT -->
## Contact

:red_circle: Please free to open a ticket on Github.

:arrow_up: [Go on TOP](#about-the-project) :point_up:

## Acknowledgements

* :tada: [@Visibilityspots](https://github.com/visibilityspots/dockerfile-cloudflared) :trophy:

* :tada: [@Cloudflared](https://github.com/cloudflare/cloudflared) :1st_place_medal:

* :tada: [@PiHole](https://github.com/pi-hole/pi-hole) :medal_sports:

:arrow_up: [Go on TOP](#about-the-project) :point_up:
