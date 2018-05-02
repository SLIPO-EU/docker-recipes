## README - Docker image for Fagi (SLIPO-EU/Fagi)

### Build

Package project into a JAR:

    ant package

Prepare build context:

    ant prepare-docker-build

Build image:

    docker build -t local/fagi:1.1 docker-build

### Examples

Run on a pair of files `a.nt` (the left) and `b.nt` (the right) using links `links.nt`:

    docker run -it --name fagi-1 \
        --volume "$(pwd)/samples/1/rules.xml:/var/local/fagi/rules.xml:ro" \
        --volume "$(pwd)/samples/1/spec.xml:/var/local/fagi/spec.xml:ro" \
        --volume "$(pwd)/samples/1/input/a.nt:/var/local/fagi/input/a.nt:ro" \
        --volume "$(pwd)/samples/1/input/b.nt:/var/local/fagi/input/b.nt:ro" \
        --volume "$(pwd)/samples/1/input/links.nt:/var/local/fagi/input/links.nt:ro" \
        --volume "$(pwd)/volumes/1/output:/var/local/fagi/output" \
        --env TARGET_NAME=result \
        local/fagi:1.1

 


