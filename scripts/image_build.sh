#!/usr/bin/env bash

set -e

if [ -z "$CI_REGISTRY_IMAGE" ]; then
    echo "warning: \$CI_REGISTRY_IMAGE is unset"
    CI_REGISTRY_IMAGE=local-build
    CI_COMMIT_SHA=local-dirty
fi

if [[ -f ./target/modules.info ]]; then
    # readarray doesnt work on osx bash v3
    #readarray -t spc_modules < ./target/modules.info
    spc_modules=($(cut -d$'\n' -f1 ./target/modules.info))
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

if [[ ! -d ./target/artifacts ]]; then
    echo "error: artifacts are missing"
    exit 1
fi

# build
for module in "${spc_modules[@]}"
do
    artifact_name=${module}-${spc_version}
    artifact_file=${artifact_name}.jar
    artifact_path=./target/artifacts/${artifact_file}

    if [[ ! -f "${artifact_path}" ]]; then
        echo "warning: $artifact_path is missing"
        continue
    fi

    cp ${artifact_path} ./target/docker
    docker build \
      --build-arg ARTIFACT_NAME=${artifact_name} \
      -t ${CI_REGISTRY_IMAGE}/${module}:${CI_COMMIT_SHA} ./target/docker
    rm -rf ./target/docker/${artifact_file}
done

if [[ ${CI_REGISTRY_IMAGE} == local-build ]]; then
    echo "error: push invalid on local builds"
    exit 1
fi

for module in "${spc_modules[@]}"
do
    image_path=${CI_REGISTRY_IMAGE}/${module}
    image_version=${image_path}:${spc_version}

    docker tag ${image_path}:${CI_COMMIT_SHA} ${image_version}
    docker tag ${image_path}:${CI_COMMIT_SHA} ${image_path}:latest
    docker push ${image_path}
done
