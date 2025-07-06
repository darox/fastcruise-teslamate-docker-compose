FROM nginx:mainline-alpine3.22
RUN apk add --no-cache apache2-utils
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"] 