#!/bin/bash
# Demyx
# https://demyx.sh

# Get versions
DEMYX_DOCKER_COMPOSE_ALPINE_VERSION=$(/usr/bin/docker exec "$DEMYX_REPOSITORY" /bin/cat /etc/os-release | /bin/grep VERSION_ID | /usr/bin/cut -c 12- | /usr/bin/sed -e 's/\r//g')
DEMYX_DOCKER_COMPOSE_VERSION=$(/usr/bin/docker exec "$DEMYX_REPOSITORY" /usr/bin/"$DEMYX_REPOSITORY" --version | awk -F '[ ]' '{print $3}' | /usr/bin/cut -c -6 | /usr/bin/sed -e 's/\r//g')

# Replace versions
/usr/bin/sed -i "s|alpine-.*.-informational|alpine-${DEMYX_DOCKER_COMPOSE_ALPINE_VERSION}-informational|g" README.md
/usr/bin/sed -i "s|docker--compose-.*.-informational|docker--compose-${DEMYX_DOCKER_COMPOSE_VERSION}-informational|g" README.md

# Echo versions to file
/bin/echo "DEMYX_DOCKER_COMPOSE_ALPINE_VERSION=$DEMYX_DOCKER_COMPOSE_ALPINE_VERSION
DEMYX_DOCKER_COMPOSE_VERSION=$DEMYX_DOCKER_COMPOSE_VERSION" > VERSION

# Push back to GitHub
/usr/bin/git config --global user.email "travis@travis-ci.org"
/usr/bin/git config --global user.name "Travis CI"
/usr/bin/git remote set-url origin https://${DEMYX_GITHUB_TOKEN}@github.com/demyxco/"$DEMYX_REPOSITORY".git
# Commit VERSION first
/usr/bin/git add VERSION
/usr/bin/git commit -m "ALPINE $DEMYX_DOCKER_COMPOSE_ALPINE_VERSION, DOCKER-COMPOSE $DEMYX_DOCKER_COMPOSE_VERSION"
/usr/bin/git push origin HEAD:master
# Commit the rest
/usr/bin/git add .
/usr/bin/git commit -m "Travis Build $TRAVIS_BUILD_NUMBER"
/usr/bin/git push origin HEAD:master

# Send a PATCH request to update the description of the repository
/bin//bin/echo "Sending PATCH request"
DEMYX_DOCKER_TOKEN="$(/usr/bin/curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'"$DEMYX_USERNAME"'", "password": "'"$DEMYX_PASSWORD"'"}' "https://hub.docker.com/v2/users/login/" | /usr/local/bin/jq -r .token)"
DEMYX_RESPONSE_CODE="$(/usr/bin/curl -s --write-out "%{response_code}" --output /dev/null -H "Authorization: JWT ${DEMYX_DOCKER_TOKEN}" -X PATCH --data-urlencode full_description@"README.md" "https://hub.docker.com/v2/repositories/${DEMYX_USERNAME}/${DEMYX_REPOSITORY}/")"
/bin//bin/echo "Received response code: $DEMYX_RESPONSE_CODE"

# Return an exit 1 code if response isn't 200
[[ "$DEMYX_RESPONSE_CODE" != 200 ]] && exit 1
