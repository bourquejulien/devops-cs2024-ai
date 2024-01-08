#!/bin/bash
set -e

TEAM_NAME=$1
ACR_NAME=$2
DOMAIN_NAME=$3

REPO_NAME="${ACR_NAME}.azurecr.io"

IMAGE_TAG="latest"
PROJECT_NAME="validation"
CLUSTER_NAME="ai"
IMAGE_NAME="${REPO_NAME}/${PROJECT_NAME}:${IMAGE_TAG}"

az acr login -n "$ACR_NAME"
docker build --target final -t "$IMAGE_NAME" -f ./Validation/Dockerfile .
docker push "$IMAGE_NAME"
az aks get-credentials --overwrite-existing --resource-group "CS-${TEAM_NAME}-rg" --name "${CLUSTER_NAME}cluster"

VARIABLES+=("--set=image.repository=\"${REPO_NAME}/${PROJECT_NAME}\"")
VARIABLES+=("--set=image.tag=\"${IMAGE_TAG}\"")
VARIABLES+=("--set=ingress.hosts[0].host=\"ai${TEAM_NAME}.${DOMAIN_NAME}\"")
VARIABLES="$(IFS=" " ; echo "${VARIABLES[*]}")"

if ! (helm ls  | grep $PROJECT_NAME) then
   echo "Installing Helm Chart"
   eval helm install -f helm/values.yaml $PROJECT_NAME helm/ $VARIABLES
else
   echo "Upgrading Helm Chart"
   eval helm upgrade -f helm/values.yaml $PROJECT_NAME helm/ $VARIABLES
fi
