#!/bin/bash -x

sample_dir=${1}

if [ ! -d "${sample_dir}" ]; then
    echo "No such directory (${sample_dir})" && exit 1;
fi
sample_dir=$(realpath ${sample_dir})
sample_name=$(basename ${sample_dir})

config_file="${sample_dir}/config.xml"
if [ ! -f "${config_file}" ]; then
    echo "This sample contains no configuration (config.xml)!" && exit 1;
fi

if [ ! -d "${PWD}/volumes" ]; then
    echo "A directory for output volumes is missing (expected at ${PWD}/volumes)" && exit 1
fi

container_name="limes-$(echo -n "${sample_name}"| tr '[:space:]-' '_' | tr '[:upper:]' '[:lower:]')"
docker run -it --name ${container_name} \
    --volume "${sample_dir}/config.xml:/var/local/limes/config.xml:ro" \
    --volume "${sample_dir}/input/a.nt:/var/local/limes/input/a.nt:ro" \
    --volume "${sample_dir}/input/b.nt:/var/local/limes/input/b.nt:ro" \
    --volume "${PWD}/volumes/${sample_name}/output:/var/local/limes/output" \
    "local/limes:1.5.7"

