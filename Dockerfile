FROM alpine

LABEL sh.demyx.image        demyx/docker-compose
LABEL sh.demyx.maintainer   Demyx <info@demyx.sh>
LABEL sh.demyx.url          https://demyx.sh
LABEL sh.demyx.github       https://github.com/demyxco
LABEL sh.demyx.registry     https://hub.docker.com/u/demyx

# Set default variables
ENV DOCKER_COMPOSE_ROOT     /demyx
ENV DOCKER_COMPOSE_CONFIG   /etc/demyx
ENV DOCKER_COMPOSE_LOG      /var/log/demyx
ENV TZ                      America/Los_Angeles

# Configure Demyx
RUN set -ex; \
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    \
    install -d -m 0755 -o demyx -g demyx "$DOCKER_COMPOSE_ROOT"; \
    install -d -m 0755 -o demyx -g demyx "$DOCKER_COMPOSE_CONFIG"; \
    install -d -m 0755 -o demyx -g demyx "$DOCKER_COMPOSE_LOG"

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/latest-stable/community' >> /etc/apk/repositories; \
    apk --update --no-cache add docker-compose dumb-init tzdata

WORKDIR "$DOCKER_COMPOSE_ROOT"

ENTRYPOINT ["dumb-init", "docker-compose"]
