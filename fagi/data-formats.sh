#/bin/bash

function data_format_to_extension() 
{
    set +x

    format=${1}
    extension=
    case ${format} in
    TURTLE|TTL|ttl)
        extension="ttl";;
    N3|n3)
        extension="n3";;
    *)
        extension="nt";;
    esac

    echo ${extension}
}
