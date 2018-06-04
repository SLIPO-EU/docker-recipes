## README - Docker image for Deer (dice-group/deer)

### Build

Using a Maven 3.5.x container (on Java 1.9) as the build environment.

Create a local Maven repository, resolve project dependencies:

    mkdir -p .m2-repo
    docker run -it --rm --workdir /usr/local/deer --volume "$PWD/.m2-repo:/root/.m2" --volume "$PWD/deer:/usr/local/deer" maven:3.5.3-jdk-9 \
        mvn dependency:resolve

Build a shaded JAR localy:

    docker run -it --rm --workdir /usr/local/deer --volume "$PWD/.m2-repo:/root/.m2" --volume "$PWD/deer:/usr/local/deer" maven:3.5.3-jdk-9 \
        mvn clean package shade:shade -Dmaven.test.skip=true -Dmaven.javadoc.skip=true

Build the target image (only target JAR is copied):

    docker build -t local/deer:1.0.2 .
    docker tag local/deer:1.0.2 athenarc/deer:1.0

### Examples

Run an example:

    docker run --name deer-1 -it \
        --volume "$PWD/samples/1/config.ttl:/var/local/deer/config.ttl:ro" \
        --volume "$PWD/volumes/1/output:/var/local/deer/output:rw" \
        local/deer:1.0.2

