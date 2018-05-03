#!/bin/bash -x

set -e

if [ -z "${RULES_FILE}" ]; then
    echo "The rules configuration file is not given (specify RULES_FILE)" && exit 1
fi
if [ ! -f "${RULES_FILE}" ]; then
    echo "The rules configuration file (${RULES_FILE}) is not readable" && exit 1
fi

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

if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "The output directory does not exist (point OUTPUT_DIR to a directory inside the container)" && exit 1
fi
output_dir="${OUTPUT_DIR%%/}"

#
# Build a custom configuration file based on defaults and given environment variables
#

spec_file=$(mktemp -p /var/local/fagi -t spec-XXXXXXX.xml)
cp spec-default.xml ${spec_file}

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

test -n "${LOCALE}" && xmlstarlet ed --inplace --update specification/locale -v "${LOCALE}" ${spec_file}

xmlstarlet ed --inplace --update specification/inputFormat -v "${INPUT_FORMAT}" ${spec_file}
xmlstarlet ed --inplace --update specification/outputFormat -v "${OUTPUT_FORMAT}" ${spec_file}

xmlstarlet ed --inplace --update specification/similarity -v "${SIMILARITY}" ${spec_file}

xmlstarlet ed --inplace --update specification/left/id -v "${LEFT_ID}" ${spec_file}
xmlstarlet ed --inplace --update specification/left/file -v "${LEFT_FILE}" ${spec_file}
xmlstarlet ed --inplace --update specification/left/categories -v "${LEFT_CLASSIFICATION_FILE}" ${spec_file}

xmlstarlet ed --inplace --update specification/right/id -v "${RIGHT_ID}" ${spec_file}
xmlstarlet ed --inplace --update specification/right/file -v "${RIGHT_FILE}" ${spec_file}
xmlstarlet ed --inplace --update specification/right/categories -v "${RIGHT_CLASSIFICATION_FILE}" ${spec_file}

xmlstarlet ed --inplace --update specification/links/id -v "${LINKS_ID}" ${spec_file}
xmlstarlet ed --inplace --update specification/links/file -v "${LINKS_FILE}" ${spec_file}

xmlstarlet ed --inplace --update specification/target/outputDir -v "${output_dir}" ${spec_file}
xmlstarlet ed --inplace --update specification/target/id -v "${TARGET_ID}" ${spec_file}

target_mode=$(echo ${TARGET_MODE} | tr '[:upper:]' '[:lower:]') # normalize to lowercase (as expected)
xmlstarlet ed --inplace --update specification/target/mode -v "${target_mode}" ${spec_file}

test -n "${TARGET_A_NAME}" && xmlstarlet ed --inplace --update specification/target/fileA -v "${output_dir}/${TARGET_A_NAME}.${output_extension}" ${spec_file}
test -n "${TARGET_B_NAME}" && xmlstarlet ed --inplace --update specification/target/fileB -v "${output_dir}/${TARGET_B_NAME}.${output_extension}" ${spec_file}
test -n "${TARGET_C_NAME}" && xmlstarlet ed --inplace --update specification/target/fileC -v "${output_dir}/${TARGET_C_NAME}.${output_extension}" ${spec_file}
test -n "${TARGET_REVIEW_NAME}" && xmlstarlet ed --inplace --update specification/target/ambiguous -v "${output_dir}/${TARGET_REVIEW_NAME}.${output_extension}" ${spec_file}
test -n "${TARGET_STATS_NAME}" && xmlstarlet ed --inplace --update specification/target/stats -v "${output_dir}/${TARGET_STATS_NAME}.txt" ${spec_file}

#
# Run command
#

exec java ${JAVA_XX_OPTS} ${JAVA_MEM_OPTS} -Dlog4j.configurationFile=log4j2.xml -jar fagi-standalone.jar -spec ${spec_file} -rules ${RULES_FILE}
