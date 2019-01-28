#!/bin/bash

MAX_MEMORY_SIZE=$(( 64 * 1024 * 1024 * 1024 ))

DEFAULT_PERCENTAGE=80

function determine_max_heap_size_in_megabytes()
{
    percentage=${1:-${DEFAULT_PERCENTAGE}}
    memory_size=$(cat /sys/fs/cgroup/memory/memory.memsw.limit_in_bytes)
    if (( memory_size > 0 && memory_size < MAX_MEMORY_SIZE )); then
        max_heap_size=$(( memory_size * percentage / 100 / 1024 / 1024 ))
        echo ${max_heap_size}
    fi   
}

function max_heap_size_as_java_option()
{
    max_heap_size=$(determine_max_heap_size_in_megabytes)
    if [ -n "${max_heap_size}" ]; then 
        echo "-Xmx${max_heap_size}m"
    fi
}
