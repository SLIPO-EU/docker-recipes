#!/bin/bash -x

DEER_VERSION="2.2.0"

sample_dir=${1}

if [ ! -d "${sample_dir}" ]; then
    echo "No such directory (${sample_dir})" && exit 1;
fi
sample_dir=$(realpath ${sample_dir})
sample_name=$(basename ${sample_dir})

config_file="${sample_dir}/config.ttl"
if [ ! -f "${config_file}" ]; then
    echo "This sample contains no configuration (config.ttl)!" && exit 1;
fi

# Prepare volumes for container
mkdir -p "$PWD/volumes/${sample_name}"
:>"$PWD/volumes/${sample_name}/deer-analytics.json"
:>"$PWD/volumes/${sample_name}/enriched.nt"

# Run container
container_name="deer-$(echo -n "${sample_name}"| tr '[:space:][.]-' '_' | tr '[:upper:]' '[:lower:]')"
docker run -it --name "${container_name}" \
    --env "OUTPUT_NAME=enriched" \
    --volume "${sample_dir}/config.ttl:/var/local/deer/config.ttl:ro" \
    --volume "${sample_dir}/input/fused.nt:/var/local/deer/input/fused.nt:ro" \
    --volume "$PWD/volumes/${sample_name}/deer-analytics.json:/var/local/deer/deer-analytics.json:rw"  \
    --volume "$PWD/volumes/${sample_name}/enriched.nt:/var/local/deer/output/enriched.nt:rw" \
    --memory "3072m" --memory-swap "4096m" \
    "local/deer:${DEER_VERSION}"

