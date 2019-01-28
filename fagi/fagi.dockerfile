# vim: set syntax=dockerfile:

FROM openjdk:8-jdk

ENV FAGI_VERSION "1.2"

RUN apt-get update && apt-get install -y xmlstarlet
RUN mkdir /var/local/fagi /usr/local/fagi

WORKDIR /usr/local/fagi/

COPY fagi.jar run-fagi.sh heap-size-funcs.sh log4j2.xml config-default.xml ./

#
# Define environment
#

ENV VERBOSE="false"

ENV INPUT_FORMAT="NT" OUTPUT_FORMAT="NT"

ENV SIMILARITY="" LOCALE="" RULES_FILE="/var/local/fagi/rules.xml"

ENV LEFT_ID="a" LEFT_FILE="/var/local/fagi/input/a.nt" LEFT_CLASSIFICATION_FILE="" LEFT_DATE=""

ENV RIGHT_ID="b" RIGHT_FILE="/var/local/fagi/input/b.nt" RIGHT_CLASSIFICATION_FILE="" RIGHT_DATE=""

ENV LINKS_ID="links" LINKS_FILE="/var/local/fagi/input/links.nt" LINKS_FORMAT=""

ENV OUTPUT_DIR="/var/local/fagi/output/"
ENV TARGET_MODE="AA_MODE" TARGET_ID="ab" TARGET_FUSED_NAME="fused" TARGET_REMAINING_NAME="remaining" TARGET_REVIEW_NAME="review" TARGET_STATS_NAME="stats"

#
# Define command
#

RUN chmod +x run-fagi.sh
CMD ["./run-fagi.sh"]

