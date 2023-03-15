FROM node:current-alpine as builder

# for updates, see: https://github.com/OHDSI/Atlas/releases
ARG ATLAS_VERSION="2.12.1"

RUN apk add --no-cache \
    ca-certificates \
    curl \
  ;

WORKDIR /build

RUN set -eux; \
  get_release() { \
    curl -sSL -o /pkg.tgz "https://github.com/OHDSI/Atlas/archive/v${ATLAS_VERSION}.tar.gz"; \
    tar -xzf /pkg.tgz; \
    find "Atlas-${ATLAS_VERSION}" -maxdepth 1 -mindepth 1 -exec 'mv' '{}' './' ';'; \
    rmdir "Atlas-${ATLAS_VERSION}"; \
    rm /pkg.tgz; \
  }; \
  get_master() { \
    git clone --depth 1 "https://github.com/OHDSI/Atlas.git" "__REPO__"; \
    find "__REPO__" -maxdepth 1 -mindepth 1 -exec 'mv' '{}' './' ';'; \
    rmdir "__REPO__"; \
  }; \
  if [ "$ATLAS_VERSION" = "master" ]; \
  then get_master; \
  else get_release; \
  fi

RUN set -eux; \
  npm install; \
  npm run build:docker; \
  npm prune --production;

# create pre-compressed copies of served assets; but do not keep compressed
# files that are larger than their uncompressed conterparts
RUN set -eux; \
  PROCS=$(grep -c '^processor\t' /proc/cpuinfo); \
  find . \
    -type f \
    "(" \
      -name '*.js' \
      -or -name '*.html' \
      -or -name '*.json' \
      -or -name '*.png' \
      -or -name '*.less' \
      -or -name '*.css' \
      -or -name '*.xml' \
      -or -name '*.jpg' \
      -or -name '*.svg' \
      -or -name '*.gif' \
    ")" \
    -not -name "config-local.js" \
    -print0 \
    | xargs -0 -n 1 -P "$PROCS" gzip -9 -kf; \
  set +x; \
  find . \
    -name '*.gz' \
    -print \
    | while read -r gzfile; do \
      dir="$(dirname "$gzfile")"; \
      base="$(basename "$gzfile" ".gz")"; \
      size="$(stat -c '%s' "$dir/$base")"; \
      gzsize="$(stat -c '%s' "$gzfile")"; \
      if [ "$gzsize" -ge "$size" ]; then rm "$gzfile"; fi; \
    done;

# clean the build for the next step
RUN rm -rf \
    README.md \
    build \
    package-*

# Production Nginx image
FROM nginxinc/nginx-unprivileged:stable-alpine
LABEL maintainer="edenceHealth <https://edence.health/>"

# verify that the base image is running as the expected user
RUN set -eux; \
  [ "$(id)" = "uid=101(nginx) gid=101(nginx) groups=101(nginx)" ]

# Document root for nginx configuration
WORKDIR /usr/share/nginx/html

# Copy content from build stage
COPY --from=builder /build .

# Configure webserver
COPY optimization.conf /etc/nginx/conf.d/
COPY 40-atlas-envsubst.sh /docker-entrypoint.d/

# Load Atlas local config with runtime user as owner so that it can be modified
# with env substitution at startup
COPY --chown=nginx config-local.js js/config-local.js
