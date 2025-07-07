#!/bin/sh
set -e
echo '*** RUNNING CUSTOM ENTRYPOINT.SH ***'
if [ -z "$NGINX_AUTH_USER" ] || [ -z "$NGINX_AUTH_PASSWORD" ]; then
  echo "NGINX_AUTH_USER and NGINX_AUTH_PASSWORD must be set" >&2
  exit 1
fi
htpasswd -bc /etc/nginx/.htpasswd "$NGINX_AUTH_USER" "$NGINX_AUTH_PASSWORD"
exec nginx -g 'daemon off;' 