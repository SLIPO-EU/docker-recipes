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

if [ ! -d "${INPUT_DIR}" ]; then
    echo "The input directory does not exist (point INPUT_DIR to a directory inside the container)" && exit 1
fi
input_dir="${INPUT_DIR%%/}"

if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "The output directory does not exist (point OUTPUT_DIR to a directory inside the container)" && exit 1
fi
output_dir="${OUTPUT_DIR%%/}"

grid_size=$((GRID_SIZE + 0))
if (( grid_size < 2 )); then
    echo "Expected the number of partitions (GRID_SIZE) to be greater or equal to 2" && exit 1
fi
for i in $(seq 1 ${grid_size}); do
    partition_dir="${input_dir}/partition_${i}"
    if [ ! -d "${partition_dir}" ]; then
        echo "Expected to find a partition (i=${i}) inside input directory: ${partition_dir}" && exit 1
    fi
done

#
# Build a custom configuration file based on defaults and given environment variables
#

config_file=$(mktemp -p /var/local/fagi -t merge-XXXXXXX.xml)
cp merge-default.xml ${config_file}

. ./data-formats.sh

input_extension=$(data_format_to_extension ${INPUT_FORMAT})

if [ "${input_extension}" != "${LEFT_FILE##*.}" ]; then
    echo "The left input file has an extension (${LEFT_FILE##*.}) not matching to input format" && exit 1;
fi
if [ "${input_extension}" != "${RIGHT_FILE##*.}" ]; then
    echo "The right input file has an extension (${RIGHT_FILE##*.}) not matching to input format" && exit 1;
fi

output_extension=$(data_format_to_extension ${OUTPUT_FORMAT})

xmlstarlet ed --inplace --update merge/partitions -v "${grid_size}" ${config_file}
xmlstarlet ed --inplace --update merge/fusionMode -v "${TARGET_MODE}" ${config_file}

xmlstarlet ed --inplace --update merge/datasetA -v "${LEFT_FILE}" ${config_file}
xmlstarlet ed --inplace --update merge/datasetB -v "${RIGHT_FILE}" ${config_file}
xmlstarlet ed --inplace --update merge/unlinkedA -v "${input_dir}/unlinked-A.${input_extension}" ${config_file}
xmlstarlet ed --inplace --update merge/unlinkedB -v "${input_dir}/unlinked-B.${input_extension}" ${config_file}
xmlstarlet ed --inplace --update merge/partialOutputDirName -v "${PARTIAL_OUTPUT_DIR_NAME}" ${config_file}

xmlstarlet ed --inplace --update merge/inputDir -v "${input_dir}/" ${config_file}

xmlstarlet ed --inplace --update merge/target/outputDir -v "${output_dir}/" ${config_file}
xmlstarlet ed --inplace --update merge/target/fused -v "${output_dir}/${TARGET_FUSED_NAME}.${output_extension}" ${config_file}
xmlstarlet ed --inplace --update merge/target/remaining -v "${output_dir}/${TARGET_REMAINING_NAME}.${output_extension}" ${config_file}
xmlstarlet ed --inplace --update merge/target/ambiguous -v "${output_dir}/${TARGET_REVIEW_NAME}.${output_extension}" ${config_file}
xmlstarlet ed --inplace --update merge/target/statistics -v "${output_dir}/${TARGET_STATS_NAME}.json" ${config_file}
xmlstarlet ed --inplace --update merge/target/fusionLog -v "${output_dir}/fusionLog.txt" ${config_file}
xmlstarlet ed --inplace --update merge/target/fusionProperties -v "${output_dir}/fusion.properties" ${config_file}

#
# Run command
#

. ./heap-size-funcs.sh
JAVA_OPTS="-Xms128m $(max_heap_size_as_java_option)"

exec java ${JAVA_OPTS} -Dlog4j.configurationFile=log4j2.xml -jar fagi-merger.jar -config ${config_file}
