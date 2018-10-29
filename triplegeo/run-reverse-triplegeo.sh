#!/bin/bash -x

set -e

CLASSPATH="triplegeo.jar:lib/*"
MAIN_CLASS="eu.slipo.athenarc.triplegeo.ReverseExtractor"
JAVA_OPTS="-Xms128m"

if [ ! -f "${CONFIG_FILE}" ]; then
    echo "No configuration given (specify CONFIG_FILE in environment)!" 1>&2
    exit 1
fi

if [ ! -f "${SPARQL_FILE}" ]; then
    echo "No SPARQL query file is given (specify SPARQL_FILE in environment)!" 1>&2
    exit 1
fi

if [ -z "${OUTPUT_NAME}" ]; then
    echo "No output name is given (specify OUTPUT_NAME in environment)"
    exit 1
fi

#
# Build a custom configuration file based on environment variables and given configuration file
#

config_file=$(mktemp -p "/var/local/triplegeo" -t options-XXXXXXX.conf)
cp ${CONFIG_FILE} ${config_file}

output_format=$(sed -rn -e 's~^outputFormat[ ]*=[ ]*(.*)~\1~p' ${config_file})
if [ -z "${output_format}" ]; then
    output_format=CSV
    sed -i -e "1 i outputFormat = ${output_format}" ${config_file}
fi

output_extension=
case ${output_format} in
SHAPEFILE|shapefile)
  output_extension="shp";;
*)
  output_extension="csv";;
esac

output_dir="${OUTPUT_DIR%%/}"

sed -i -e "/^outputFile[ ]*=/ d" -e "/^outputFormat[ ]*=/ a outputFile = ${output_dir}/${OUTPUT_NAME}.${output_extension}" ${config_file}

sed -i -e "/^tmpDir[ ]*=/ d" -e "/^outputFile[ ]*=/ a tmpDir = /tmp" ${config_file}

# The INPUT_FILE may be a single file or a list of colon-separated input files
# Split and join by ';' as expected by triplegeo
input_files=$(IFS=':' p=( $INPUT_FILE ); IFS=';'; echo "${p[*]}")
sed -i -e "/^inputFiles[ ]*=/ d" -e "/^outputFormat[ ]*=/ a inputFiles = ${input_files}" ${config_file}

sed -i -e "/^sparqlFile[ ]*=/ d" -e "/^inputFiles[ ]*=/ a sparqlFile = ${SPARQL_FILE}" ${config_file}

#
# Run command
#

MAX_MEMORY_SIZE=$(( 64 * 1024 * 1024 * 1024 ))

memory_size=$(cat /sys/fs/cgroup/memory/memory.memsw.limit_in_bytes)
if (( memory_size > 0 && memory_size < MAX_MEMORY_SIZE )); then
    max_heap_size=$(( memory_size * 80 / 100 ))
    JAVA_OPTS="${JAVA_OPTS} -Xmx$(( max_heap_size / 1024 / 1024 ))m"
fi

exec java ${JAVA_OPTS} -cp ${CLASSPATH} ${MAIN_CLASS} ${config_file}
