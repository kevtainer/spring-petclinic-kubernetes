#!/bin/bash

if [[ -f ./target/modules.info ]]; then
    readarray -t spc_modules < ./target/modules.info
else
    echo "error: modules.info file is missing"
    exit 1
fi

if [[ -f ./target/version.info ]]; then
    spc_version=$(<./target/version.info)
else
    echo "error: version.info is missing"
    exit 1
fi

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

if [ -z "$INGRESS_IP" ]; then
  echo "No INGRESS_IP environment variable set. Is your repository CI/CD configured properly?"
  exit 1
fi

echo "Using tiller in namespace $TILLER_NAMESPACE"

WILDCARD_HOST=spc.${INGRESS_IP}.nip.io
SERVICE_PREFIX=spring-petclinic-

for module in "${spc_modules[@]}"
do
    INGRESS_OVERRIDE=""
    service_name=$(echo "$module" | grep -oP "^$SERVICE_PREFIX\K.*")

    echo "Current release:"
    helm ls --tiller-namespace "$TILLER_NAMESPACE" --namespace "$KUBE_NAMESPACE" ${service_name}

    image_path=${CI_REGISTRY_IMAGE}/${module}
    image_versioned=${image_path}:${spc_version}

    if [ service_name == "admin-server" ]; then
        INGRESS_OVERRIDE="ingress.hosts={admin.${WILDCARD_HOST}},"
    fi

    echo
    echo "Deploying ${service_name} :: ${spc_version} (git ${CI_COMMIT_TAG:-$CI_COMMIT_REF_NAME} $CI_COMMIT_SHA)"
    set -x
    helm upgrade --install --reset-values \
        --tiller-namespace "$TILLER_NAMESPACE" --namespace "$KUBE_NAMESPACE" \
        --set="${INGRESS_OVERRIDE}fullnameOverride=${service_name},imageTag=${spc_version}" \
        --values helm/spring-petclinic-kubernetes/values.${service_name}.yaml \
        ${service_name} helm/spring-petclinic-kubernetes
    { set +x; } 2>/dev/null
done
