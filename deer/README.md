## README - Docker image for Deer (dice-group/deer)

### Build

Using a Maven 3.6.x container (on Java 11) as the build environment.

Create a local Maven repository: 

    mkdir -p .m2-repo

Resolve project dependencies:

    docker run -it --rm --workdir /usr/local/deer --volume "$PWD/.m2-repo:/root/.m2" --volume "$PWD/deer:/usr/local/deer" \
        maven:3.6.2-jdk-11-slim mvn dependency:resolve

Resolve dependencies for Deer SLIPO plugin:

    docker run -it --rm --workdir /usr/local/deer-slipo-plugin --volume "$PWD/.m2-repo:/root/.m2" --volume "$PWD/deer-slipo-plugin:/usr/local/deer-slipo-plugin" \
        maven:3.6.2-jdk-11-slim mvn dependency:resolve

Build (shaded) JAR for Deer:

    docker run -it --rm --workdir /usr/local/deer --volume "$PWD/.m2-repo:/root/.m2" --volume "$PWD/deer:/usr/local/deer" \
        maven:3.6.2-jdk-11-slim mvn clean package shade:shade -Dmaven.test.skip=true -Dmaven.javadoc.skip=true

Build JAR for Deer SLIPO plugin:

    docker run -it --rm --workdir /usr/local/deer-slipo-plugin --volume "$PWD/.m2-repo:/root/.m2" --volume "$PWD/deer-slipo-plugin:/usr/local/deer-slipo-plugin" \
        maven:3.6.2-jdk-11-slim mvn clean package
    
Build the target image (only target JAR is copied):

    docker build -t local/deer:2.2.0 .
    docker tag local/deer:2.2.0 athenarc/deer:2.2

### Examples

Run an example:

    docker run --name deer-1 -it \
        --volume "$PWD/samples/1/config.ttl:/var/local/deer/config.ttl:ro" \
        --volume "$PWD/samples/1/input/1.nt:/var/local/deer/input/fused.nt:ro" \
        --volume "$PWD/volumes/1/output:/var/local/deer/output:rw" \
        local/deer:2.2.0

