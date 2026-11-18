FROM ghcr.io/gohugoio/hugo:v0.170.1 AS build
COPY --chown=hugo:hugo . /project
WORKDIR /project
RUN hugo --minify --destination /tmp/public

# Runs as non-root (uid 101) and listens on 8080
FROM docker.io/nginxinc/nginx-unprivileged:1.30.6-alpine
# Override the labels inherited from the nginx image
LABEL org.opencontainers.image.title="mahahe-website" \
      org.opencontainers.image.url="https://www.mahahe.it" \
      org.opencontainers.image.source="https://github.com/mahahe-it/mahahe-website" \
      org.opencontainers.image.description="www.mahahe.it and the legacy helm.mahahe.it chart repository" \
      org.opencontainers.image.licenses="Apache-2.0"
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /tmp/public /usr/share/nginx/html
EXPOSE 8080
