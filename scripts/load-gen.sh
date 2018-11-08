#!/bin/sh

# Changing the NUM_CLIENTS environment variable varies the load on the application
# The bigger the number the more requests, the bigger the load

# Set SILENT to anything to have all output discarded. Useful when running load for
# a long time to stop the disk filling up with copious log messages
# -e 'SILENT=1'

REPO=${REPO:registry.gitlab.com/opentracing-workshop/spring-petclinic-kubernetes/spc-load:latest}

echo "running in background"
docker run \
    -d \
    --rm \
    --network=host \
    -e 'HOST=http://localhost:8080' \
    -e 'NUM_CLIENTS=1' \
    -e 'SILENT=1' \
    ${REPO}