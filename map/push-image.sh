#!/bin/bash

set -e

USERNAME="brqu"
IMAGE_NAME="jungle-map"
IMAGE_TAG="latest"
IMAGE_NAME="${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

docker build --target final -t "$IMAGE_NAME" .
docker push "$IMAGE_NAME"
