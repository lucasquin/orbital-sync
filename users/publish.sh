#!/bin/bash

API_NAME="users"
VERSION="latest"
GITHUB_USER="lucasquin"

docker build -t ghcr.io/${GITHUB_USER}/users:${VERSION} .
docker push ghcr.io/${GITHUB_USER}/${API_NAME}:${VERSION}
