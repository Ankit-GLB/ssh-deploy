#!/bin/bash

set -e
# if [[ "${MODE}" != 1 ]]; then exit 0; fi

# List of environment variables
#  EC2_USERNAME
#  EC2_HOSTNAME
#  EC2_SSH_KEY
#  DOCKER_USERNAME
#  DOCKER_PASSWORD
#  REPO_NAME
#  REPO_TAG
#  APP_NAME
#  SCRIPT_CODE
#  APP_PORT
#  HOST_PORT
#  ENV_STRING

initiate(){
  # Create ssh keys
  chmod 777 script.sh
  touch key.pem
  chmod 600 key.pem
  echo "${EC2_SSH_KEY}" > key.pem
};

cleanup(){
  # Remove ssh key
  rm key.pem
};

echo "running entrypoint.sh"

# some logic here
# -z for empty/unset
# -n for not empty
if [[ -z "${SCRIPT_CODE}" ]]; then # checks if SCRIPT_CODE is empty/null
  SCRIPT_CODE=$(cat ./script.sh);
  # echo "Using user provided script: ${SCRIPT_CODE}";
else
  echo "Using default script"
fi

initiate;

echo "App deployment started"

touch .env

# Required environment variables (current count: 7)
echo DOCKER_USERNAME=${DOCKER_USERNAME} >> .env
echo DOCKER_PASSWORD=${DOCKER_PASSWORD} >> .env
echo REPO_NAME=${REPO_NAME} >> .env
echo REPO_TAG=${REPO_TAG} >> .env
echo APP_NAME=${APP_NAME} >> .env
echo APP_PORT=${APP_PORT} >> .env
echo HOST_PORT=${HOST_PORT} >> .env

mkdir ${APP_NAME}
# cp ./script.sh ./${APP_NAME}
cd ${APP_NAME}
# Adding extra environment variables
touch .env
echo ${ENV_STRING} >> .env
echo "Total env. lines count: $(cat .env | wc -l)"
rm -rf ${APP_NAME}

ssh -i ./key.pem -o StrictHostKeyChecking=no "${EC2_USERNAME}"@"${EC2_HOSTNAME}" <<< "${SCRIPT_CODE}"

ssh_status=$?

if [[ "${ssh_status}" -eq 0 ]]; then
  echo "App deployed successfully!";
else
  echo "App deployment failed!"
  exit "${ssh_status}"
fi;

echo "Cleanup started"
cleanup;
echo "Cleanup done!"

echo "exiting entrypoint.sh"