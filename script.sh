#!/bin/bash

echo "running script.sh"

# echo "env. list"
# echo ${ENV_STRING} > .env
# cat .env

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

if [[ $? != 0 ]]; then
    exit 1;
fi;

sudo docker pull "${DOCKER_USERNAME}/${REPO_NAME}":"${REPO_TAG}"

if [[ $? != 0 ]]; then
    exit 1;
fi;

echo "app_name: ${APP_NAME}" 
echo "app_port: ${APP_PORT}" 
echo "host_port: ${HOST_PORT}" 

sudo docker kill "${APP_NAME}"

sudo docker rm "${APP_NAME}" 

sudo docker run --name "${APP_NAME}" -d -p "${HOST_PORT}":"${APP_PORT}" "${DOCKER_USERNAME}/${REPO_NAME}":"${REPO_TAG}"

if [[ $? != 0 ]]; then
    exit 1;
fi;

echo "exiting script.sh"