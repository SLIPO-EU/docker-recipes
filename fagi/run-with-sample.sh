#!/bin/bash

sample=${1}

test -z "${sample}" && sample="1"

config_properties_file="samples/${sample}/config.properties"

if [ ! -d "samples/${sample}" ]; then
    echo "No such directory (samples/$sample)" && exit 1;
fi
if [ ! -f "${config_properties_file}" ]; then
    echo "This sample contains no configuration!" && exit 1;
fi

fusion_mode=$(cat "${config_properties_file}" | grep -o -P -e '(?<=^target\.mode[[:space:]]=[[:space:]])([^[:space:]])+$')

container_name="fagi-test-$(echo -n "${sample}"| tr '[:space:]-' '_' | tr '[:upper:]' '[:lower:]')"
docker run -it --name ${container_name} \
    --volume "$(pwd)/samples/${sample}/rules.xml:/var/local/fagi/rules.xml:ro" \
    --volume "$(pwd)/samples/${sample}/input/a.nt:/var/local/fagi/input/a.nt:ro" \
    --volume "$(pwd)/samples/${sample}/input/b.nt:/var/local/fagi/input/b.nt:ro" \
    --volume "$(pwd)/samples/${sample}/input/links.nt:/var/local/fagi/input/links.nt:ro" \
    --volume "$(pwd)/volumes/${sample}/output:/var/local/fagi/output" \
    --env "VERBOSE=true" \
    --env "TARGET_MODE=${fusion_mode}" \
    --env "TARGET_FUSED_NAME=fused" \
    --env "TARGET_REMAINING_NAME=remaining" \
    --env "TARGET_REVIEW_NAME=review" \
    athenarc/fagi:1.2

