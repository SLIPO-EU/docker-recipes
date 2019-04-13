## README - Docker image for Limes (dice-group/LIMES)

### Build

Package project into a JAR:

    ant package

Prepare build context:

    ant prepare-docker-build

Build image:

    docker build -t local/limes:1.5.7 docker-build

### Examples

Run on a pair of N-TRIPLES input files:

    docker run -it --name limes-1 \
        --volume "$(pwd)/samples/1/config.xml:/var/local/limes/config.xml:ro" \
        --volume "$(pwd)/samples/1/input/a.nt:/var/local/limes/input/a.nt:ro" \
        --volume "$(pwd)/samples/1/input/b.nt:/var/local/limes/input/b.nt:ro" \
        --volume "$(pwd)/volumes/1/output:/var/local/limes/output" \
        local/limes:1.5.7


