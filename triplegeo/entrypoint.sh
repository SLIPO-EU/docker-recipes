#!/bin/bash -x

set -e

CLASSPATH=target/triplegeo-${TRIPLEGEO_VERSION}.jar


if [ -z "${CONFIG_FILE}" ]; then
    echo "Cannot find configuration file (CONFIG_FILE)!" 1>&2
    exit 1
fi

#
# Build a custom configuration file (derived from given configuration) 
#

config_file=$(mktemp -p /var/local/triplegeo -t options-XXXXXXX.conf)
cp ${CONFIG_FILE} ${config_file}

if [ -f "${INPUT_FILE}" ]; then
    sed -i -e "s~^inputFiles[ ]*=[ ]*.*$~inputFiles = ${INPUT_FILE}~"  ${config_file}
fi

if [ -f "${OUTPUT_DIR}" ]; then
    sed -i -e "s~^outputDir[ ]*=[ ]*.*$~outputDir = ${OUTPUT_DIR}~"  ${config_file}
fi

#
# Run command
#

MAIN_CLASS=eu.slipo.athenarc.triplegeo.Executor

exec java ${JAVA_XX_OPTS} ${JAVA_MEM_OPTS} -cp ${CLASSPATH} ${MAIN_CLASS} ${config_file}
