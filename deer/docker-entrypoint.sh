#!/bin/bash -x

set -e

JAVA_OPTS="-Xms128m"


if [ -z "${CONFIG_FILE}" ]; then
    echo "The configuration is missing (specify CONFIG_FILE in environment)!" 1>&2
    exit 1
fi
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "The configuration file is not readable" 1>&2
    exit 1
fi

input_file=${INPUT_FILE}
if [ -z "${input_file}" ]; then
    echo "The input is missing (specify INPUT_FILE in environment)!" 1>&2
    exit 1
fi
if [[ ${input_file} =~ ^\/.* ]]; then
    if [[ ${input_file} =~ ^\/var\/local\/deer/.* ]]; then
        input_file=${input_file#/var/local/deer/}
    else
       echo "The input file is outside of working directory"
       exit 1
    fi
fi
if [ ! -f "${input_file}" ]; then
    echo "The input file is not readable" 1>&2
    exit 1
fi

output_dir="${OUTPUT_DIR%%/}"
if [ -z "${output_dir}" ]; then
    echo "The output directory is missing (specify OUTPUT_DIR in environment)!" 1>&2
    exit 1
fi
if [[ ${output_dir} =~ ^\/.* ]]; then
    if [[ ${output_dir} =~ ^\/var\/local\/deer/.* ]]; then
        output_dir=${output_dir#/var/local/deer/}
    else
       echo "The output directory is outside of working directory"
       exit 1
    fi
fi
if [ ! -d "${output_dir}" ]; then
    echo "The output directory is not a directory!" 1>&2
    exit 1
fi

#
# Build a custom configuration file based on environment variables and given configuration file
#

config_file=$(mktemp -p /var/local/deer -t config-XXXXXXX.ttl)
cp ${CONFIG_FILE} ${config_file}

output_format=
output_extension=
case ${OUTPUT_FORMAT} in
NT|N-TRIPLES|N_TRIPLES|nt)
  output_format="N-TRIPLES"
  output_extension="nt"
  ;;
TTL|ttl|Turtle)
  output_format="Turtle"
  output_extension="ttl"
  ;;
N3|n3|Notation3)
  output_format="N3"
  output_extension="n3"
  ;;
*)
  output_format="N-TRIPLES"
  output_extension="nt"
  ;;
esac

# Todo: The following should be more selective, now it matches every fromUri!
sed -i -e "s~^\([[:space:]]*\)[:]fromUri[[:space:]]\+\"\([^\"]*\)\"~\1:fromUri \"${input_file}\"~" ${config_file}

sed -i -e "/^[:]output_node[[:space:]]*$/,/^[:].*/ s~\([[:space:]]*\):outputFile[[:space:]]\+\"\([^\"]*\)\"~\1:outputFile \"${output_dir}/output.${output_extension}\"~" ${config_file}

sed -i -e "/^[:]output_node[[:space:]]*$/,/^[:].*/ s~\([[:space:]]*\):outputFormat[[:space:]]\+\"\([^\"]*\)\"~\1:outputFormat \"${output_format}\"~" ${config_file}

#
# Run command
#

MAX_MEMORY_SIZE=$(( 64 * 1024 * 1024 * 1024 ))

memory_size=$(cat /sys/fs/cgroup/memory/memory.memsw.limit_in_bytes)
if (( memory_size > 0 && memory_size < MAX_MEMORY_SIZE )); then
    max_heap_size=$(( memory_size * 80 / 100 ))
    JAVA_OPTS="${JAVA_OPTS} -Xmx$(( max_heap_size / 1024 / 1024 ))m"
fi

jar_file="/usr/local/deer/deer-cli-${DEER_VERSION}.jar"

exec java ${JAVA_OPTS} -jar ${jar_file} ${config_file}
