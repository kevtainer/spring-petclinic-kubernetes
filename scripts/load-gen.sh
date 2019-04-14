#!/bin/sh

# Changing the NUM_CLIENTS environment variable varies the load on the application
# The bigger the number the more requests, the bigger the load

# Set SILENT to anything to have all output discarded. Useful when running load for
# a long time to stop the disk filling up with copious log messages
# -e 'SILENT=1'

set -ex

REPO=${REPO:-registry.gitlab.com/opentracing-workshop/spring-petclinic-kubernetes/spc-load:latest}
NUM_CLIENTS={$NUM_CLIENTS:-3}
INJECT=${INJECT:-0}
SILENT=${SILENT:-1}
SPC_HOST=${SPC_HOST:-http://localhost:8080}

echo "running in background"
docker run \
    --rm \
    --network=host \
    -e "HOST=${SPC_HOST}" \
    -e "NUM_CLIENTS=${NUM_CLIENTS}" \
    -e "INJECT=${INJECT}" \
    -e "SILENT=${SILENT}" \
    ${REPO}