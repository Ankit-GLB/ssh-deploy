#!/bin/bash

set -e

echo "running script.sh"

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

sudo docker pull "${REPO_NAME}":"${REPO_TAG}"

sudo docker stop -t 30 "${APP_NAME}:${REPO_TAG}" 2>/dev/null # wait for 30 sec before sending SIGKILL signal

sudo docker rm "${APP_NAME}:${REPO_TAG}" 2>/dev/null

sudo docker run --name "${APP_NAME}:${REPO_TAG}" -d -p 443:"${APP_PORT}" -p 80:"${APP_PORT}" "${REPO_NAME}":"${REPO_TAG}"
        
echo "exiting script.sh"