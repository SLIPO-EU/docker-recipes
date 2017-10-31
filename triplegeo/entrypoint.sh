#!/bin/bash -x

set -e

CLASSPATH="target/triplegeo-${TRIPLEGEO_VERSION}.jar:target/lib/*"

MAIN_CLASS=eu.slipo.athenarc.triplegeo.Executor

if [ -z "${CONFIG_FILE}" ]; then
    echo "Cannot find configuration file (specify CONFIG_FILE in environment)!" 1>&2
    exit 1
fi

#
# Build a custom configuration file based on environment variables and given configuration file
#

config_file=$(mktemp -p /var/local/triplegeo -t options-XXXXXXX.conf)
cp ${CONFIG_FILE} ${config_file}

if [ -d "${OUTPUT_DIR}" ]; then
    sed -i -e "s~^outputDir[ ]*=[ ]*.*$~outputDir = ${OUTPUT_DIR}~"  ${config_file}
fi

# The INPUT_FILE may be a single file or a list of colon-separated input files
if [ -n "${INPUT_FILE}" ]; then
    # Split and join by ';' as expected by triplegeo
    input_files=$(IFS=':' p=( $INPUT_FILE ); IFS=';'; echo "${p[*]}")
    # Edit configuration file
    sed -i -e "s~^inputFiles[ ]*=[ ]*.*$~inputFiles = ${input_files}~"  ${config_file}
fi

if [ -n "${DB_URL}" ]; then
    if [ -n "${INPUT_FILE}" ]; then
        echo "The input resources are contradicting (DB_URL and INPUT_FILE are both present)!" 1>&2;
        exit 1;
    fi
    # Parse a url expected as "jdbc:<jdbc-provider>://<host>:<port>/<database>". 
    if [[ ! "${DB_URL}" =~  ^jdbc: ]]; then
        echo "The connection URL is malformed" 1>&2
        echo "Note: The connection URL is expected as jdbc:<jdbc-provider>://<host>[:<port>]/<database>" 1>&2;
        exit 1;
    fi
    url=${DB_URL#jdbc:}
    db_provider=$(IFS=: p=( $url ); echo ${p[0]})
    if [ -z "${db_provider}" ]; then
        echo "The connection URL is malformed (no database provider?)" 1>&2;
        exit 1;
    else 
        # Parse connection url
        u1=${url#${db_provider}://}
        db_address=$(IFS='/' p=( $u1 ); echo ${p[0]})
        db_name=$(IFS='/' p=( $u1 ); echo ${p[1]})
        db_host=$(IFS=':' p=( $db_address ); echo ${p[0]})
        db_port=$(IFS=':' p=( $db_address ); echo ${p[1]})
        # Map to triplegeo-specific dbType, add port defaults
        if [[ ${db_provider} == 'postgresql' ]]; then
            db_type='PostGIS'
            db_port=${db_port:-"5432"}
        elif [[ ${db_provider} == 'mysql' ]]; then
            db_type='MySQL'
            db_port=${db_port:-"3306"}
        fi
        # Edit configuration file
        sed -i -e "s~^dbType[ ]*=[ ]*.*$~dbType = ${db_type}~"  ${config_file}
        sed -i -e "s~^dbName[ ]*=[ ]*.*$~dbName = ${db_name}~"  ${config_file}
        sed -i -e "s~^dbHost[ ]*=[ ]*.*$~dbHost = ${db_host}~"  ${config_file}
        sed -i -e "s~^dbPort[ ]*=[ ]*.*$~dbPort = ${db_port}~"  ${config_file}
    fi
fi

if [ -n "${DB_USERNAME}" ]; then
    sed -i -e "s~^dbUserName[ ]*=[ ]*.*$~dbUserName = ${DB_USERNAME}~"  ${config_file}
fi

if [ -n "${DB_PASSWORD_FILE}" ] && [ -f "${DB_PASSWORD_FILE}" ]; then
    db_password=$(cat ${DB_PASSWORD_FILE})
    sed -i -e "s~^dbPassword[ ]*=[ ]*.*$~dbPassword = ${db_password}~"  ${config_file}
fi


#
# Run command
#

exec java ${JAVA_XX_OPTS} ${JAVA_MEM_OPTS} -cp ${CLASSPATH} ${MAIN_CLASS} ${config_file}

