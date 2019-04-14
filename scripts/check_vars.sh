#!/bin/bash

if [ ! -z "$INGRESS_IP" ]; then
  echo "INGRESS_IP: ${INGRESS_IP}"
  VAR_SET=1
fi

if [ ! -z "$UCP_HOSTNAME" ]; then
  echo "UCP_HOSTNAME: ${UCP_HOSTNAME}"
  VAR_SET=1
fi

if [ -z "$VAR_SET" ]; then
  echo "Unable to find parameter which is used to set hostnames for Ingress, did you set the environment variable specific to the platform for this tutorial?"
  echo "GKE users: INGRESS_IP must be set"
  echo "Docker EE users: UCP_HOSTNAME must be set"
  echo "Unable to continue, exiting"
  exit 1
fi