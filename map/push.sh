#!/bin/bash
set -e

FORCE_LOGIN=false
REGISTRY="index.docker.io/v1"
BASE_PATH="brqu"
TAG="latest"
IMAGE="jungle-map"

while [[ $# -gt 0 ]]; do
  case $1 in
    -f)
      FORCE_LOGIN=true
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

if $FORCE_LOGIN || ! grep --quiet $REGISTRY ~/.docker/config.json ; then
    echo "Enter Docker username:"
    read -r USER
    echo "Enter Docker password/token:"
    read -r -s PASSWORD
    
    echo "$PASSWORD" | docker login -u "$USER" --password-stdin $REGISTRY
    
    if ! [ $? -eq 0 ] ; then
       echo "Login failed"
       exit 1
    fi
else
    echo "Already logged in $REGISTRY"
fi

printf "\n----------------------\nNow building $BASE_PATH/$IMAGE:$TAG images:\n----------------------\n"
DOCKER_BUILDKIT=1 docker build -t "$BASE_PATH/$IMAGE:$TAG" .

printf "\n----------------------\nNow pushing $BASE_PATH/$IMAGE:$TAG images:\n----------------------\n"
docker push "$BASE_PATH/$IMAGE:$TAG"
