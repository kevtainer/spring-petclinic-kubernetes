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

_helm() {
    echo "> helm $@\
"
    helm $@
}

if [ ! -z "$INGRESS_IP" ]; then
  echo "Found INGRESS_IP, generating a nip.io wildcard host"
  BASE_HOSTNAME=${INGRESS_IP}.nip.io
fi

if [ ! -z "$UCP_HOSTNAME" ]; then
  echo "Found UCP_HOSTNAME, using that as the wildcard host"
  BASE_HOSTNAME=${UCP_HOSTNAME}
fi

if [ -z "$BASE_HOSTNAME" ]; then
  echo "Unable to find BASE_HOSTNAME, did you set the environment variable specific to the platform for this tutorial?"
  echo "GKE users: INGRESS_IP must be set"
  echo "Docker EE users: UCP_HOSTNAME must be set"
  echo ""
  echo "Defaulting to localhost, goodluck"
  BASE_HOSTNAME=localhost
fi

# generate ssl cert for teh ingress (not very useful, so it's commented out)
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=*.${BASE_HOSTNAME}"
#kubectl -n spc create secret tls spc-tls-cert --key=tls.key --cert=tls.crt
#rm -rf tls.key tls.crt

# ingress rules for petclinic application @todo move this to the actual app helm template (if possible)
_helm upgrade --install --reset-values \
  --tiller-namespace ${TILLER_NAMESPACE} --namespace ${KUBE_NAMESPACE} \
  --set ingress.hosts={spc.${BASE_HOSTNAME}} \
  --values helm/spring-petclinic-ingress-rules/values.yaml \
  spc-ingress-rules helm/spring-petclinic-ingress-rules

# get stable repo
_helm repo update

# database server for petclinic application
_helm upgrade --install --reset-values \
  --tiller-namespace ${TILLER_NAMESPACE} --namespace ${KUBE_NAMESPACE} \
  --set=fullnameOverride=database-server \
  --values helm/spring-petclinic-database-server/values.yaml \
  database-server stable/mysql

# install kafka (using local repo because their hosted chart breaks storage on single node installs as of 8/8/19)
_helm upgrade --install \
  --tiller-namespace ${TILLER_NAMESPACE} --namespace ${KUBE_NAMESPACE} \
  --values helm/spring-petclinic-kafka-server/values.yaml \
  kafka-oss ../helm/cp-helm-charts


