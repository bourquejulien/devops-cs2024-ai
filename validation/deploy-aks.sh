#!/bin/bash
set -e

INFO_COLOR="\e[1;34m"
OK_COLOR="\e[1;32m"
WARNING_COLOR="\e[3;31m"
ENDCOLOR="\e[0m"

DOMAIN_NAME=dev.cs2024.one
IMAGE_TAG="latest"
PROJECT_NAME="validation"
CLUSTER_NAME="ai"
GLOBAL_RG="Global-rg"

echo -e "${INFO_COLOR}Retrieving random id:${ENDCOLOR}"
RANDOM_ID=$(az acr list --resource-group Global-rg | jq -r ".[0].name")
echo "$RANDOM_ID"

ACR_NAME="${RANDOM_ID}"
REPO_NAME="$ACR_NAME.azurecr.io"
TABLE_NAME="ta${RANDOM_ID}"
IMAGE_NAME="${REPO_NAME}/${PROJECT_NAME}:${IMAGE_TAG}"

echo -e "${INFO_COLOR}Retrieving table storage key...${ENDCOLOR}"
TABLE_KEY=$(az storage account keys list --resource-group "$GLOBAL_RG" --account-name "$TABLE_NAME" |  jq -r ".[0].value")

echo -e "${INFO_COLOR}Pushing to ACR:${ENDCOLOR}"
az acr login -n "$ACR_NAME"
docker build --target final -t "$IMAGE_NAME" -f ./Validation/Dockerfile .
docker push "$IMAGE_NAME"

deploy_to_aks () {
    az aks get-credentials --overwrite-existing --resource-group "CS-$1-rg" --name "${CLUSTER_NAME}cluster"

    VARIABLES+=("--set=image.repository=\"${REPO_NAME}/${PROJECT_NAME}\"")
    VARIABLES+=("--set=image.tag=\"${IMAGE_TAG}\"")
    VARIABLES+=("--set=ingress.hosts[0].host=\"ai$1.${DOMAIN_NAME}\"")

    VARIABLES+=("--set=container.env[2].value=\"$1\"")
    VARIABLES+=("--set=container.env[3].value=\"${TABLE_NAME}\"")
    VARIABLES+=("--set=container.env[4].value=\"${TABLE_KEY}\"")

    VARIABLES="$(IFS=" " ; echo "${VARIABLES[*]}")"

    if ! (helm ls  | grep $PROJECT_NAME) then
        echo "Installing Helm Chart"
        eval helm install -f helm/values.yaml $PROJECT_NAME helm/ $VARIABLES
    else
        echo "Upgrading Helm Chart"
        eval helm upgrade -f helm/values.yaml $PROJECT_NAME helm/ $VARIABLES
    fi
}

echo -e "\n${INFO_COLOR}Deploying to clusters:${ENDCOLOR}"

while IFS= read -r line; do
    [[ -z $line ]] && continue

    if [[ ${line:0:1} = \# ]]; then
        echo -e "${WARNING_COLOR}Skipping: $line${ENDCOLOR}"
        continue
    fi

    echo -e "\n${OK_COLOR}Pushing to team: $line${ENDCOLOR}"
    deploy_to_aks "$line"
done
