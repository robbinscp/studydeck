FROM nginx:alpine
RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*
COPY study-tool-v2.html /usr/share/nginx/html/index.html
EXPOSE 80
