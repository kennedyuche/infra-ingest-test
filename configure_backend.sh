#!/usr/bin/env bash

export RESOURCE_GROUP_NAME=docai-devs
export STORAGE_ACCOUNT_NAME=tfstatedocai
export CONTAINER_NAME=tfstate
export LOCATION=northeurope

# Create resource group
RESOURCE_GROUP_RESULT=$(az group exists --resource-group "$RESOURCE_GROUP_NAME")
if [ "$RESOURCE_GROUP_RESULT" = "false" ]; then
    az group create --name "$RESOURCE_GROUP_NAME" --location $LOCATION
fi

# Create storage account
STORAGE_ACCOUNT_RESULT=$(az storage account check-name --name $STORAGE_ACCOUNT_NAME --query nameAvailable)
if [ "$STORAGE_ACCOUNT_RESULT" = "true" ]; then
    az storage account create --name "$STORAGE_ACCOUNT_NAME" --location $LOCATION --resource-group "$RESOURCE_GROUP_NAME" --sku Standard_LRS
fi

# Create blob container
CONTAINER_RESULT=$(az storage container exists --name "$CONTAINER_NAME" --account-name $STORAGE_ACCOUNT_NAME | jq .exists)
if [ "$CONTAINER_RESULT" = "false" ]; then
    az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT_NAME"
fi


# export arm access key
# ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP_NAME" --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
# export ARM_ACCESS_KEY=$ACCOUNT_KEY
# echo $ARM_ACCESS_KEY

# add this key as a secret in github 