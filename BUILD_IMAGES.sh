#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail # Causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero return value

AGENT_REPO_BASE_PATH=$1
IMAGE_TAG=$2
PUSH=$3

for filename in dockerfiles/Dockerfile*; do
    IMAGE_REPO_TAG="matankaholo/agent-${filename#"dockerfiles/Dockerfile-"}:${IMAGE_TAG}"
    echo ${IMAGE_REPO_TAG,,}
    docker build -f $filename -t ${IMAGE_REPO_TAG,,} ${AGENT_REPO_BASE_PATH} &
done

while true; do echo "Waiting for all containers build to finish"; ! ps -afe | grep "[d]ocker build -f dockerfiles" > /dev/null && break; sleep 30; done

if [[ "$PUSH" == "push" ]]
then
    for filename in dockerfiles/Dockerfile*; do
        docker push ${IMAGE_REPO_TAG,,}
    done
fi
