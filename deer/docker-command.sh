#!/bin/bash -x

set -e

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
        # Relativize input path (as expected by Deer)
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
        # Relativize output path (as expected by Deer)
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
output_file=
case "${OUTPUT_FORMAT}" in
NT|N-TRIPLES|N-TRIPLE|N_TRIPLES|nt)
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
output_file="${output_dir}/${OUTPUT_NAME}.${output_extension}"

sed_script="/var/local/deer/$(basename ${config_file}).sed"
cat >${sed_script} <<EOD
/^[:]fullInput[[:space:]]*$/,/^[:].*/ { 
    s~^\([[:space:]]*\)deer[:]fromPath[[:space:]]\+\"\([^\"]*\)\"~\1deer:fromPath "${input_file}"~
}
/^[:]output_node[[:space:]]*$/,/^[:].*/ {
    s~\([[:space:]]*\)deer[:]outputFile[[:space:]]\+\"\([^\"]*\)\"~\1deer:outputFile "${output_file}"~
    s~\([[:space:]]*\)deer[:]outputFormat[[:space:]]\+\"\([^\"]*\)\"~\1deer:outputFormat "${output_format}"~
}
EOD
sed -i -f ${sed_script} ${config_file}

#
# Run command
#

. "/usr/local/deer/heap-size-funcs.sh"
JAVA_OPTS="-Xms128m $(max_heap_size_as_java_option)"

jar_file="/usr/local/deer/deer-cli-${DEER_VERSION}.jar"

exec java ${JAVA_OPTS} -jar ${jar_file} ${config_file}
