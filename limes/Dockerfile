FROM openjdk:8-jdk

ENV LIMES_VERSION "1.3.0"

RUN apt-get update && apt-get install -y xmlstarlet
RUN mkdir /var/local/limes

WORKDIR /usr/local/limes/

COPY limes-standalone.jar docker-entrypoint.sh ./

#
# Define environment
#

## Enviroment for Java runtime ##

ENV JAVA_XX_OPTS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
ENV JAVA_MEM_OPTS "-Xmx256m -Xms64m"

## Environment for program invocation ##

ENV CONFIG_FILE "/var/local/limes/config.xml"

# Specify an output directory (overrides configuration file) 
ENV OUTPUT_DIR "/var/local/limes/output/"

ENV SOURCE_FILE "/var/local/limes/input/a.nt"
ENV TARGET_FILE "/var/local/limes/input/b.nt"

ENV ACCEPTED_NAME "accepted"
ENV REVIEW_NAME "review"

#
# Define entrypoint
#

RUN chmod +x docker-entrypoint.sh
CMD ["./docker-entrypoint.sh"]
