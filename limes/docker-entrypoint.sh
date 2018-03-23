#!/bin/bash -x

set -e

if [ -z "${CONFIG_FILE}" ]; then
    echo "Cannot find configuration file (specify CONFIG_FILE in environment)!" 1>&2
    exit 1
fi

#
# Build a custom configuration file based on environment variables and given configuration file
#

config_file=$(mktemp -p /var/local/limes -t config-XXXXXXX.xml)
cp ${CONFIG_FILE} ${config_file}

#
# Edit configuration file according to environment
#

if [ -d "${OUTPUT_DIR}" ]; then
    output_dir="${OUTPUT_DIR%%/}/"
    xmlstarlet ed --inplace --update LIMES/ACCEPTANCE/FILE -v "${output_dir}/accepted.nt" ${config_file}
    xmlstarlet ed --inplace --update LIMES/REVIEW/FILE -v "${output_dir}/review.nt" ${config_file}
fi

if [ -n "${SOURCE_FILE}" ]; then
    xmlstarlet ed --inplace --update LIMES/SOURCE/ENDPOINT -v ${SOURCE_FILE} ${config_file}
fi

if [ -n "${TARGET_FILE}" ]; then
    xmlstarlet ed --inplace --update LIMES/TARGET/ENDPOINT -v ${TARGET_FILE} ${config_file}
fi

#
# Run command
#

exec java ${JAVA_XX_OPTS} ${JAVA_MEM_OPTS} -jar limes-standalone.jar ${config_file}
