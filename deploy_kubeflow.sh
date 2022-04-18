#!/bin/sh
set -euo pipefail

function log {
  echo "$@"
  return 0
}

export ENV_INFO=dev
export TF_LOG=info

  if [ "$ENV_INFO" = "dev" ]; then
   log '✅ Configuring Dev Environment'
   source ../.env/dev.env
  elif [ "$ENV_INFO" = "stg" ];  then
   log '✅ Configuring Stg Environment'
   source ../.env/stg.env
  elif [ "$ENV_INFO" = "prod" ];  then
   log '✅ Configuring Prod Environment'
   source ../.env/prod.env
 fi


 # Variables we need in the application secrets
 log '🌐 Configure all environment variables needed'

 source ../.env/dev.env


# Create resource group
log '✅ create resource group if none exist yet'
RESOURCE_GROUP_RESULT=$(az group exists --resource-group "${TF_VAR_resource_group_name}")
if [ "$RESOURCE_GROUP_RESULT" = "false" ]; then
    az group create --name "${TF_VAR_resource_group_name}" --location ${TF_VAR_resource_group_location}
fi

sleep 1m

# Create storage account
log '✅ create storage account for tfstate if none exist yet'
STORAGE_ACCOUNT_RESULT=$(az storage account check-name --name $STATE_STORAGE_ACCOUNT_NAME --query nameAvailable)
if [ "$STORAGE_ACCOUNT_RESULT" = "true" ]; then
    az storage account create --name "$STATE_STORAGE_ACCOUNT_NAME" --location ${TF_VAR_resource_group_location} --resource-group "${TF_VAR_resource_group_name}" --sku Standard_LRS
fi

sleep 1m

# Create blob container
log '✅ create blob container for tfstate if none exist yet'
BLOB_CONTAINER_RESULT=$(az storage container exists --name "$BLOB_CONTAINER_NAME" --account-name $STATE_STORAGE_ACCOUNT_NAME | jq .exists)
if [ "$BLOB_CONTAINER_RESULT" = "false" ]; then
    az storage container create --name "$BLOB_CONTAINER_NAME" --account-name "$STATE_STORAGE_ACCOUNT_NAME"
fi

sleep 1m

# export arm access key
export STORAGE_ACCESS_KEY=$(az storage account keys list --resource-group "${TF_VAR_resource_group_name}" --account-name $STATE_STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

log '✅ STORAGE_ACCESS_KEY:' ${STORAGE_ACCESS_KEY}

log '✅ register providers scoped to roles'
az provider register --namespace 'Microsoft.ContainerService'
az provider register --namespace 'Microsoft.DBforPostgreSQL'
az provider register --namespace 'Microsoft.ContainerRegistry'

sleep 1m

# connect to azure kubernetes cluster
az aks get-credentials --resource-group "${TF_VAR_resource_group_name}" --name "${TF_VAR_cluster_name}" --overwrite-existing

sleep 1m

# clone kubeflow manifest git repository
cd ~
log "🏗️ Cloning into kubeflow manifest repo";
git clone https://github.com/MavenCode/kubeflow-manifest.git
cd kubeflow-manifest

sleep 1m

export KUBEFLOW_NAMESPACE_NAME=kubeflow
export KUBEFLOW_USER_NAMESPACE_NAME=kubeflow-user

# create kubeflow namespace
NS=$(kubectl get namespace $KUBEFLOW_NAMESPACE_NAME --ignore-not-found);
if [[ "$NS" ]]; then
  log "✅ Skipping creation of namespace $KUBEFLOW_NAMESPACE_NAME - already exists";
else
  log "🏗️ Creating namespace $KUBEFLOW_NAMESPACE_NAME";
  kubectl create namespace $KUBEFLOW_NAMESPACE_NAME;
fi;

# create kubeflow-user namespace
NS=$(kubectl get namespace $KUBEFLOW_USER_NAMESPACE_NAME --ignore-not-found);
if [[ "$NS" ]]; then
  log "✅ Skipping creation of namespace $KUBEFLOW_USER_NAMESPACE_NAME - already exists";
else
  log "🏗️ Creating namespace $KUBEFLOW_USER_NAMESPACE_NAME";
  kubectl create namespace $KUBEFLOW_USER_NAMESPACE_NAME;
fi;


# install kubeflow with spark-operator
log "✅ Installing kubeflow with spark-operator to ${TF_VAR_cluster_name}";
while ! kustomize build install-kubeflow | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

sleep 5m


# list deployed pods
log "✅ Listing all deployed PODs"
kubectl get pods -A | egrep 'NAME|^auth|^cert-manager|^istio-system|^knative-|^kubeflow'

# patch istio-ingressgateway as Loadbalancer
log "✅ Patching istio-ingressgateway as LoadBalancer"
kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec": {"type": "LoadBalancer"}}'

# view the exposed external IP address of istio-ingressgateway service
log "✅ Exposing the external IP address of istio-ingressgateway service"
kubectl get svc istio-ingressgateway -n istio-system

sleep 2m

kubectl get svc istio-ingressgateway -n istio-system
