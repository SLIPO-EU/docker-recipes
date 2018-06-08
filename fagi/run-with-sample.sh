#!/bin/bash

sample_number=${1}
test -z "${sample_number}" && sample_number=1

if [ ! -d "samples/${sample_number}" ]; then
    echo "No such directory (samples/$sample_number)" && exit 1
fi

docker run -it --rm --name fagi-t${sample_number} \
    --volume "$(pwd)/samples/${sample_number}/rules.xml:/var/local/fagi/rules.xml:ro" \
    --volume "$(pwd)/samples/${sample_number}/input/a.nt:/var/local/fagi/input/a.nt:ro" \
    --volume "$(pwd)/samples/${sample_number}/input/b.nt:/var/local/fagi/input/b.nt:ro" \
    --volume "$(pwd)/samples/${sample_number}/input/links.nt:/var/local/fagi/input/links.nt:ro" \
    --volume "$(pwd)/volumes/${sample_number}/output:/var/local/fagi/output" \
    --env TARGET_MODE=A_MODE \
    --env TARGET_FUSED_NAME=fused \
    --env TARGET_REMAINING_NAME=remaining \
    --env TARGET_REVIEW_NAME=review \
    athenarc/fagi:1.2

