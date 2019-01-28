#!/bin/bash -x

set -e

if [ -z "${RULES_FILE}" ]; then
    echo "The rules configuration file is not given (specify RULES_FILE)" && exit 1
fi
if [ ! -f "${RULES_FILE}" ]; then
    echo "The rules configuration file (${RULES_FILE}) is not readable" && exit 1
fi
rules_file=$(realpath ${RULES_FILE})

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
links_format_values=('nt' 'csv' 'csv-unique-links')
if [[ -n "${LINKS_FORMAT}" ]] && [[ "0" -eq $(echo ${links_format_values[@]} | grep -c -e "\\b${LINKS_FORMAT}\\b") ]]; then
    echo "The links format (${LINKS_FORMAT}) is invalid" && exit 1
fi

if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "The output directory does not exist (point OUTPUT_DIR to a directory inside the container)" && exit 1
fi
output_dir="${OUTPUT_DIR%%/}"

#
# Build a custom configuration file based on defaults and given environment variables
#

config_file=$(mktemp -p /var/local/fagi -t config-XXXXXXX.xml)
cp config-default.xml ${config_file}

#
# Determine output format/extension
#

output_extension=
case ${OUTPUT_FORMAT} in
TTL)
  output_extension="ttl";;
N3)
  output_extension="n3";;
*)
  output_extension="nt";;
esac

#
# Edit configuration file according to environment
#

test -n "${LOCALE}" && xmlstarlet ed --inplace --update specification/locale -v "${LOCALE}" ${config_file}

test -n "${VERBOSE}" && xmlstarlet ed --inplace --update specification/verbose -v "${VERBOSE}" ${config_file}

test -n "${INPUT_FORMAT}" && test "${INPUT_FORMAT}" != "NT" && \
    xmlstarlet ed --inplace --update specification/inputFormat -v "${INPUT_FORMAT}" ${config_file}

test -n "${OUTPUT_FORMAT}" && test "${OUTPUT_FORMAT}" != "NT" && \
    xmlstarlet ed --inplace --update specification/outputFormat -v "${OUTPUT_FORMAT}" ${config_file}

test -n "${SIMILARITY}" && \
    xmlstarlet ed --inplace --update specification/similarity -v "${SIMILARITY}" ${config_file}

xmlstarlet ed --inplace --update specification/rules -v "${rules_file}" ${config_file}

xmlstarlet ed --inplace --update specification/left/id -v "${LEFT_ID}" ${config_file}
xmlstarlet ed --inplace --update specification/left/file -v "${LEFT_FILE}" ${config_file}
test -n "${LEFT_CLASSIFICATION_FILE}" && xmlstarlet ed --inplace --update specification/left/categories -v "${LEFT_CLASSIFICATION_FILE}" ${config_file}
test -n "${LEFT_DATE}" && xmlstarlet ed --inplace --update specification/left/date -v "${LEFT_DATE}" ${config_file}

xmlstarlet ed --inplace --update specification/right/id -v "${RIGHT_ID}" ${config_file}
xmlstarlet ed --inplace --update specification/right/file -v "${RIGHT_FILE}" ${config_file}
test -n "${RIGHT_CLASSIFICATION_FILE}" && xmlstarlet ed --inplace --update specification/right/categories -v "${RIGHT_CLASSIFICATION_FILE}" ${config_file}
test -n "${RIGHT_DATE}" && xmlstarlet ed --inplace --update specification/right/date -v "${RIGHT_DATE}" ${config_file}

xmlstarlet ed --inplace --update specification/links/id -v "${LINKS_ID}" ${config_file}
xmlstarlet ed --inplace --update specification/links/file -v "${LINKS_FILE}" ${config_file}
test -n "${LINKS_FORMAT}" && xmlstarlet ed --inplace --update specification/links/linksFormat -v "${LINKS_FORMAT}" ${config_file}

xmlstarlet ed --inplace --update specification/target/outputDir -v "${output_dir}" ${config_file}
xmlstarlet ed --inplace --update specification/target/id -v "${TARGET_ID}" ${config_file}

target_mode=$(echo ${TARGET_MODE} | tr '[:upper:]' '[:lower:]') # normalize to lowercase (as expected)
xmlstarlet ed --inplace --update specification/target/mode -v "${target_mode}" ${config_file}

test -n "${TARGET_FUSED_NAME}" && \
    xmlstarlet ed --inplace --update specification/target/fused -v "${output_dir}/${TARGET_FUSED_NAME}.${output_extension}" ${config_file}
test -n "${TARGET_REMAINING_NAME}" && \
    xmlstarlet ed --inplace --update specification/target/remaining -v "${output_dir}/${TARGET_REMAINING_NAME}.${output_extension}" ${config_file}
test -n "${TARGET_REVIEW_NAME}" && \
    xmlstarlet ed --inplace --update specification/target/ambiguous -v "${output_dir}/${TARGET_REVIEW_NAME}.${output_extension}" ${config_file}
test -n "${TARGET_STATS_NAME}" && \
    xmlstarlet ed --inplace --update specification/target/statistics -v "${output_dir}/${TARGET_STATS_NAME}.json" ${config_file}
test "true" == "${VERBOSE}" && \
    xmlstarlet ed --inplace --update specification/target/fusionLog -v "${output_dir}/fusion.log" ${config_file}
    
#
# Run command
#

. ./heap-size-funcs.sh
JAVA_OPTS="-Xms128m $(max_heap_size_as_java_option)"

exec java ${JAVA_OPTS} -Dlog4j.configurationFile=log4j2.xml -jar fagi.jar -spec ${config_file}
