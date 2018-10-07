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

# @todo