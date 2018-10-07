#!/usr/bin/env bash

# sanity checks
if [ ! -d ./target ]; then
    echo "error: build target not found"
    exit 1
fi

if [[ ! $(which xml-strings) ]]; then
    echo "error: xml-strings binary not found"
    exit 1
fi

spm_file=/tmp/spm-modules.txt
( [ -e "$spm_file" ] || touch "$spm_file" ) && [ ! -w "$spm_file" ] && echo cannot write to $spm_file && exit 1

# dump a list of active modules in the project
xml-strings pom.xml :/project/modules > ${spm_file}
# trim extra lines
sed '/^$/d' ${spm_file} > ./target/modules.info
# dump project version @todo maybe version each submodule one day?
xml-printf '%s' pom.xml :/project/version > ./target/version.info

# copy docker build directory
cp -r docker ./target
