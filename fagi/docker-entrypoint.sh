#!/bin/bash -x

set -e

if [ -z "${SPEC_FILE}" ]; then
    echo "The spec configuration file is not given (specify SPEC_FILE)"
    exit 1
fi
if [ ! -f "${SPEC_FILE}" ]; then
    echo "The spec configuration file (${SPEC_FILE}) is not readable"
    exit 1
fi

if [ -z "${RULES_FILE}" ]; then
    echo "The rules configuration file is not given (specify RULES_FILE)"
    exit 1
fi
if [ ! -f "${RULES_FILE}" ]; then
    echo "The rules configuration file (${RULES_FILE}) is not readable"
    exit 1
fi

if [ -z "${LEFT_FILE}" ]; then
    echo "The left input file is not given (specify LEFT_FILE)"
    exit 1
fi
if [ ! -f "${LEFT_FILE}" ]; then
    echo "The left input file (${LEFT_FILE}) is not readable"
    exit 1
fi

if [ -z "${RIGHT_FILE}" ]; then
    echo "The right input file is not given (specify RIGHT_FILE)"
    exit 1
fi
if [ ! -f "${RIGHT_FILE}" ]; then
    echo "The right input file (${RIGHT_FILE}) is not readable"
    exit 1
fi

if [ -z "${LINKS_FILE}" ]; then
    echo "The links input file is not given (specify LINKS_FILE)"
    exit 1
fi
if [ ! -f "${LINKS_FILE}" ]; then
    echo "The links input file (${LINKS_FILE}) is not readable"
    exit 1
fi

#
# Build a custom configuration file based on environment variables and given configuration file
#

spec_file=$(mktemp -p /var/local/fagi -t spec-XXXXXXX.xml)
cp ${SPEC_FILE} ${spec_file}

#
# Determine output format/extension
#

output_format=$(cat ${spec_file}| xmlstarlet fo --dropdtd| xmlstarlet sel -t --value-of specification/outputFormat)
output_extension=
case ${output_format} in
NT)
  output_extension="nt"
  ;;
TTL)
  output_extension="ttl"
  ;;
N3)
  output_extension="n3"
  ;;
*)
  output_extension="nt"
  ;;
esac


#
# Edit configuration file according to environment
#

xmlstarlet ed --inplace --update specification/left/file -v "${LEFT_FILE}" ${spec_file}
xmlstarlet ed --inplace --update specification/right/file -v "${RIGHT_FILE}" ${spec_file}
xmlstarlet ed --inplace --update specification/links/file -v "${LINKS_FILE}" ${spec_file}

if [ -d "${OUTPUT_DIR}" ]; then
    output_dir="${OUTPUT_DIR%%/}"
    xmlstarlet ed --inplace --update specification/target/file -v "${output_dir}/${TARGET_NAME}.${output_extension}" ${spec_file}
fi

#
# Run command
#

exec java ${JAVA_XX_OPTS} ${JAVA_MEM_OPTS} -Dlog4j.configurationFile=log4j2.xml -jar fagi-standalone.jar -spec ${spec_file} -rules ${RULES_FILE}
