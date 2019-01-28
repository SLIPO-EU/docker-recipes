#!/bin/bash -x

set -e

if [ -z "${LEFT_FILE}" ]; then
    echo "The left input file is not given (specify LEFT_FILE)" && exit 1
fi
if [ ! -f "${LEFT_FILE}" ]; then
    echo "The left input file (${LEFT_FILE}) is not readable" && exit 1
fi

if [ -z "${RIGHT_FILE}" ]; then
    echo "The right input file is not given (specify RIGHT_FILE)" && exit 1
fi
if [ ! -f "${RIGHT_FILE}" ]; then
    echo "The right input file (${RIGHT_FILE}) is not readable" && exit 1
fi

if [ -z "${LINKS_FILE}" ]; then
    echo "The links input file is not given (specify LINKS_FILE)" && exit 1
fi
if [ ! -f "${LINKS_FILE}" ]; then
    echo "The links input file (${LINKS_FILE}) is not readable" && exit 1
fi
min_number_of_links=2
number_of_links=$(wc -l ${LINKS_FILE} | awk '{print $1}')
if (( number_of_links < min_number_of_links )); then
    echo "The number of links is too small (${number_of_links} < ${min_number_of_links})!" && exit 1
fi

if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "The output directory does not exist (point OUTPUT_DIR to a directory inside the container)" && exit 1
fi
output_dir="${OUTPUT_DIR%%/}"

grid_size=${GRID_SIZE:-2}
grid_size=$((grid_size + 0))
if (( grid_size < 2 )); then
    echo "The number of partitions (GRID_SIZE) must be greater or equal to 2" && exit 1
fi

#
# Build a custom configuration file based on defaults and given environment variables
#

config_file=$(mktemp -p /var/local/fagi -t partition-XXXXXXX.xml)
cp partition-default.xml ${config_file}

input_extension=
case ${INPUT_FORMAT} in
TTL)
  input_extension="ttl";;
N3)
  input_extension="n3";;
*)
  input_extension="nt";;
esac

if [ "${input_extension}" != "${LEFT_FILE##*.}" ]; then
    echo "The left input file has an extension (${LEFT_FILE##*.}) not matching to input format" && exit 1;
fi

if [ "${input_extension}" != "${RIGHT_FILE##*.}" ]; then
    echo "The right input file has an extension (${RIGHT_FILE##*.}) not matching to input format" && exit 1;
fi

xmlstarlet ed --inplace --update partitioning/partitions -v "${grid_size}" ${config_file}
xmlstarlet ed --inplace --update partitioning/fusionMode -v "${TARGET_MODE}" ${config_file}

xmlstarlet ed --inplace --update partitioning/datasetA -v "${LEFT_FILE}" ${config_file}
xmlstarlet ed --inplace --update partitioning/datasetB -v "${RIGHT_FILE}" ${config_file}
xmlstarlet ed --inplace --update partitioning/links -v "${LINKS_FILE}" ${config_file}

xmlstarlet ed --inplace --update partitioning/unlinkedA -v "${output_dir}/unlinked-A.${input_extension}" ${config_file}
xmlstarlet ed --inplace --update partitioning/unlinkedB -v "${output_dir}/unlinked-B.${input_extension}" ${config_file}
xmlstarlet ed --inplace --update partitioning/outputDir -v "${output_dir}/" ${config_file}

#
# Run command
#

. ./heap-size-funcs.sh
JAVA_OPTS="-Xms128m $(max_heap_size_as_java_option)"

exec java ${JAVA_OPTS} -Dlog4j.configurationFile=log4j2.xml -jar fagi-partitioner.jar -config ${config_file}
