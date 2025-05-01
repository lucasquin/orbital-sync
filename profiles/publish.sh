#!/bin/bash

API_NAME="profiles"
VERSION="latest"
GITHUB_USER="lucasquin"

docker build -t ghcr.io/${GITHUB_USER}/${API_NAME}:${VERSION} .
docker push ghcr.io/${GITHUB_USER}/${API_NAME}:${VERSION}
