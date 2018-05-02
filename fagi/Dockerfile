FROM openjdk:8-jdk

ENV FAGI_VERSION "1.1"

RUN apt-get update && apt-get install -y xmlstarlet
RUN mkdir /var/local/fagi

WORKDIR /usr/local/fagi/

COPY fagi-standalone.jar docker-entrypoint.sh log4j2.xml ./

#
# Define environment
#

## Enviroment for Java runtime ##

ENV JAVA_XX_OPTS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
ENV JAVA_MEM_OPTS "-Xmx256m -Xms64m"

## Environment for program invocation ##

ENV SPEC_FILE "/var/local/fagi/spec.xml"
ENV RULES_FILE "/var/local/fagi/rules.xml"

ENV OUTPUT_DIR "/var/local/fagi/output/"

ENV LEFT_FILE "/var/local/fagi/input/a.nt"
ENV RIGHT_FILE "/var/local/fagi/input/b.nt"
ENV LINKS_FILE "/var/local/fagi/input/links.nt"

ENV TARGET_NAME "fused"

#
# Define entrypoint
#

RUN chmod +x docker-entrypoint.sh
CMD ["./docker-entrypoint.sh"]

