#!/bin/bash -x

sample_dir=${1}

if [ ! -d "${sample_dir}" ]; then
    echo "No such directory (${sample_dir})" && exit 1;
fi
sample_dir=$(realpath ${sample_dir})
sample_name=$(basename ${sample_dir})

config_properties_file="${sample_dir}/config.properties"
if [ ! -f "${config_properties_file}" ]; then
    echo "This sample contains no configuration!" && exit 1;
fi

if [ ! -f "${sample_dir}/rules.xml" ]; then
    echo "This sample contains no rules (rules.xml)!" && exit 1;
fi

if [ ! -d "${PWD}/volumes" ]; then
    echo "A directory for output volumes is missing (expected at ${PWD}/volumes)" && exit 1
fi

fusion_mode=$(cat "${config_properties_file}" | grep -o -P -e '(?<=^target\.mode[[:space:]]=[[:space:]])([^[:space:]])+$')

links_extension=
links_format=
if [ -f "${sample_dir}/input/links.nt" ]; then
    links_extension="nt"
    links_format="nt"
elif [ -f "${sample_dir}/input/links.csv" ]; then
    links_extension="csv"
    links_format="csv-unique-links"
else
    echo "This sample contains no links (links.nt or links.csv)!" && exit 1;
fi

container_name="fagi-$(echo -n "${sample_name}"| tr '[:space:]-' '_' | tr '[:upper:]' '[:lower:]')"
docker run -it --name ${container_name} \
    --volume "${sample_dir}/rules.xml:/var/local/fagi/rules.xml:ro" \
    --volume "${sample_dir}/input/a.nt:/var/local/fagi/input/a.nt:ro" \
    --volume "${sample_dir}/input/b.nt:/var/local/fagi/input/b.nt:ro" \
    --volume "${sample_dir}/input/links.${links_extension}:/var/local/fagi/input/links.${links_extension}:ro" \
    --volume "${PWD}/volumes/${sample_name}/output:/var/local/fagi/output" \
    --env "VERBOSE=true" \
    --env "LINKS_FILE=/var/local/fagi/input/links.${links_extension}" \
    --env "LINKS_FORMAT=${links_format}" \
    --env "TARGET_MODE=${fusion_mode}" \
    --env "TARGET_FUSED_NAME=fused" \
    --env "TARGET_REMAINING_NAME=remaining" \
    --env "TARGET_REVIEW_NAME=review" \
    --memory="1024m" --memory-swap="1536m" \
    local/fagi:1.2

