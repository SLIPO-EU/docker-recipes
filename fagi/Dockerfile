FROM openjdk:8-jdk

ENV FAGI_VERSION "1.2"

RUN apt-get update && apt-get install -y xmlstarlet
RUN mkdir /var/local/fagi

WORKDIR /usr/local/fagi/

COPY fagi-standalone.jar docker-entrypoint.sh log4j2.xml spec-default.xml ./

#
# Define environment
#

## Enviroment for Java runtime ##

ENV JAVA_XX_OPTS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
ENV JAVA_MEM_OPTS "-Xmx256m -Xms64m"

## Environment for program invocation ##

ENV LOCALE ""

ENV INPUT_FORMAT "NT"
ENV OUTPUT_FORMAT "NT"

ENV SIMILARITY "jarowinkler"
ENV RULES_FILE "/var/local/fagi/rules.xml"

ENV LEFT_ID "a"
ENV LEFT_FILE "/var/local/fagi/input/a.nt"
ENV LEFT_CLASSIFICATION_FILE ""

ENV RIGHT_ID "b"
ENV RIGHT_FILE "/var/local/fagi/input/b.nt"
ENV RIGHT_CLASSIFICATION_FILE ""

ENV LINKS_ID "links"
ENV LINKS_FILE "/var/local/fagi/input/links.nt"

ENV OUTPUT_DIR "/var/local/fagi/output/"
ENV TARGET_MODE "AA_MODE"
ENV TARGET_ID "ab"
ENV TARGET_FUSED_NAME "fused"
ENV TARGET_REMAINING_NAME "remaining"
ENV TARGET_REVIEW_NAME "review"
ENV TARGET_STATS_NAME "stats"

#
# Define entrypoint
#

RUN chmod +x docker-entrypoint.sh
CMD ["./docker-entrypoint.sh"]

