#!/bin/bash

KUBE_NAMESPACE="${KUBE_NAMESPACE:-default}"

# Automatically use a namespace-based tiller if available,
# or the cluster-wide installed version if this is possible.
if [ -z "$TILLER_NAMESPACE" ]; then
  if [ -n "$( kubectl get pods --namespace=$KUBE_NAMESPACE -l 'app=helm,name=tiller' -o name)" ]; then
    echo "Found namespace-based tiller installation"
    TILLER_NAMESPACE=$KUBE_NAMESPACE
  elif [ "$(kubectl auth can-i create pods --subresource=portforward --namespace=kube-system)" = "yes" ]; then
    # Can connect with central installed Tiller, use it to deploy the project
    # Note this could mean that deployments have full cluster-admin access!
    TILLER_NAMESPACE="kube-system"
    echo "Found cluster-wide tiller installation"
  elif [ "$(kubectl auth can-i create pods --subresource=portforward --namespace=$NAMESPACE)" = "yes" ]; then
    # Can connect with namespace based Tiller
    TILLER_NAMESPACE="${TILLER_NAMESPACE:-$KUBE_NAMESPACE}"
  else
    echo "No RBAC permission to contact to tiller in either 'kube-system' or '$NAMESPACE'" >&2
    exit 1
  fi
fi

if [ ! -z "$INGRESS_IP" ]; then
  echo "Found INGRESS_IP, generating a nip.io wildcard host"
  WILDCARD_HOST=${INGRESS_IP}.nip.io
fi

if [ ! -z "$UCP_HOSTNAME" ]; then
  echo "Found UCP_HOSTNAME, using that as the wildcard host"
  WILDCARD_HOST=${UCP_HOSTNAME}
fi

if [ -z "$WILDCARD_HOST" ]; then
  echo "Unable to find WILDCARD_HOST, did you set the environment variable specific to the platform for this tutorial?"
  echo "GKE users: INGRESS_IP must be set"
  echo "Docker EE users: UCP_HOSTNAME must be set"
  echo "Unable to continue, exiting"
  exit 1
fi

# ingress rules for petclinic application
helm upgrade --install --reset-values \
  --tiller-namespace ${TILLER_NAMESPACE} --namespace ${KUBE_NAMESPACE} \
  --set ingress.hosts={spc.${WILDCARD_HOST}} \
  --values helm/spring-petclinic-ingress-rules/values.yaml \
  spc-ingress-rules helm/spring-petclinic-ingress-rules

# get stable repo
helm repo update

# database server for petclinic application
helm upgrade --install --reset-values \
  --tiller-namespace spc --namespace spc \
  --set=fullnameOverride=database-server \
  --values helm/spring-petclinic-database-server/values.yaml \
  database-server stable/mysql
