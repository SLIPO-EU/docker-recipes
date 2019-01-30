#!/bin/bash -x

sample_dir=${1}
grid_size=${2}

if [ ! -d "${sample_dir}" ]; then
    echo "No such directory (${sample_dir})" && exit 1;
fi
sample_dir=$(realpath ${sample_dir})
sample_name=$(basename ${sample_dir})

config_properties_file="${sample_dir}/config.properties"
if [ ! -f "${config_properties_file}" ]; then
    echo "This sample contains no configuration!" && exit 1;
fi

if [ ! -d "${PWD}/volumes" ]; then
    echo "A directory for output volumes is missing (expected at ${PWD}/volumes)" && exit 1
fi

fusion_mode=$(cat "${config_properties_file}" | grep -o -P -e '(?<=^target\.mode[[:space:]]=[[:space:]])([^[:space:]])+$')

grid_size=$((grid_size + 0))
if (( grid_size < 2 )); then
    echo "The grid_size (i.e number of partitions) must be greater or equal to 2" && exit 1
fi

container_name="fagi-merger-$(echo -n "${sample_name}"| tr '[:space:]-' '_' | tr '[:upper:]' '[:lower:]')"

docker run -it --name ${container_name} \
    --volume "${sample_dir}/input/a.nt:/var/local/fagi/input/a.nt:ro" \
    --volume "${sample_dir}/input/b.nt:/var/local/fagi/input/b.nt:ro" \
    --volume "${PWD}/volumes/${sample_name}/partitions:/var/local/fagi/partitions:ro" \
    --volume "${PWD}/volumes/${sample_name}/output:/var/local/fagi/output" \
    --env "GRID_SIZE=${grid_size}" \
    --env "TARGET_MODE=${fusion_mode}" \
    --memory="1024m" --memory-swap="1536m" \
    local/fagi-merger:1.2
