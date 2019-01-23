# Web Server Setup

This document describes how to setup a web server to serve static content.
The technology of choice is [nginx](https://www.nginx.com/), since it's fast and pretty easy to configure.

This setup can be run standalone or with a reverse proxy, like Traefik.
See `reverse_proxy` to setup!

Setup steps:
1. Put site content in `site-content` folder
2. Adjust `nginx.conf` and `docker-compose.yaml` with proper server names
3. Start up using `docker-compose up -d`