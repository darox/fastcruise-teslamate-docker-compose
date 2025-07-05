#!/bin/sh
set -e
echo '*** RUNNING CUSTOM ENTRYPOINT.SH ***'
if [ -z "$NGINX_AUTH_USER" ] || [ -z "$NGINX_AUTH_PASSWORD" ]; then
  echo "NGINX_AUTH_USER and NGINX_AUTH_PASSWORD must be set" >&2
  exit 1
fi
htpasswd -bc /etc/nginx/.htpasswd "$NGINX_AUTH_USER" "$NGINX_AUTH_PASSWORD"
# Generate self-signed cert if not present
CERT_DIR="/etc/nginx/certs"
CERT_KEY="$CERT_DIR/selfsigned.key"
CERT_CRT="$CERT_DIR/selfsigned.crt"
if [ ! -f "$CERT_KEY" ] || [ ! -f "$CERT_CRT" ]; then
  mkdir -p "$CERT_DIR"
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout "$CERT_KEY" \
    -out "$CERT_CRT" \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost"
fi
ls -l /etc/nginx/certs
exec nginx -g 'daemon off;' 