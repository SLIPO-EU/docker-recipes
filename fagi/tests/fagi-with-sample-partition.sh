#!/bin/bash -x

# NOTE: The partitioner (1.2.13) only works with NT-formatted links: this FAGI instance will expect only such links.

sample_dir=${1}
partition_number=${2}

if [ ! -d "${sample_dir}" ]; then
    echo "No such directory (${sample_dir})" && exit 1;
fi
sample_dir=$(realpath ${sample_dir})
sample_name=$(basename ${sample_dir})

if [ ! -d "${PWD}/volumes" ]; then
    echo "A directory for output volumes is missing (expected at ${PWD}/volumes)" && exit 1
fi

partition_number=$((partition_number + 0))
partition_dir="${PWD}/volumes/${sample_name}/partitions/partition_${partition_number}"
if [ ! -d "${partition_dir}" ]; then
    echo "The partition directory is missing (did you run the partitioner before?): ${partition_dir}" && exit 1
fi

config_properties_file="${sample_dir}/config.properties"
if [ ! -f "${config_properties_file}" ]; then
    echo "This sample contains no configuration!" && exit 1;
fi

if [ ! -f "${sample_dir}/rules.xml" ]; then
    echo "This sample contains no rules (rules.xml)!" && exit 1;
fi

fusion_mode=$(cat "${config_properties_file}" | grep -o -P -e '(?<=^target\.mode[[:space:]]=[[:space:]])([^[:space:]])+$')

container_name="fagi-$(echo -n "${sample_name}"| tr '[:space:]-' '_' | tr '[:upper:]' '[:lower:]')-part${partition_number}"

docker run -it --name ${container_name} \
    --volume "${sample_dir}/rules.xml:/var/local/fagi/rules.xml:ro" \
    --volume "${partition_dir}/A${partition_number}.nt:/var/local/fagi/input/a.nt:ro" \
    --volume "${partition_dir}/B${partition_number}.nt:/var/local/fagi/input/b.nt:ro" \
    --volume "${partition_dir}/links_${partition_number}.nt:/var/local/fagi/input/links.nt:ro" \
    --volume "${partition_dir}/output/:/var/local/fagi/output" \
    --env "VERBOSE=true" \
    --env "TARGET_MODE=${fusion_mode}" \
    --env "TARGET_FUSED_NAME=fused" \
    --env "TARGET_REMAINING_NAME=remaining" \
    --env "TARGET_REVIEW_NAME=ambiguous" \
    --memory="1024m" --memory-swap="1536m" \
    local/fagi:1.2

