#!/bin/bash -x

set -e

if [ ! -f "${CONFIG_FILE}" ]; then
    echo "No configuration given (specify CONFIG_FILE in environment)!" 1>&2
    exit 1
fi

#
# Build a custom configuration file based on environment variables and given configuration file
#

config_file=$(mktemp -p /var/local/deer -t config-XXXXXXX.ttl)
cp ${CONFIG_FILE} ${config_file}

# Todo: override configuration options inside ${config_file}

#
# Run command
#

exec java ${JAVA_XX_OPTS} ${JAVA_MEM_OPTS} -jar deer-cli-${DEER_VERSION}.jar ${config_file}

