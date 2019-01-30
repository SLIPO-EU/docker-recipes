# vim: set syntax=dockerfile:

FROM openjdk:8-jdk

ENV FAGI_VERSION "1.2"

RUN apt-get update && apt-get install -y xmlstarlet
RUN mkdir /var/local/fagi /usr/local/fagi

WORKDIR /usr/local/fagi/

COPY fagi-merger.jar run-fagi-merger.sh data-formats.sh heap-size-funcs.sh log4j2.xml merge-default.xml ./

#
# Define environment
#

ENV GRID_SIZE="2"

ENV INPUT_FORMAT="NT" OUTPUT_FORMAT="NT"

ENV LEFT_FILE="/var/local/fagi/input/a.nt" RIGHT_FILE="/var/local/fagi/input/b.nt"

ENV INPUT_DIR="/var/local/fagi/partitions/" PARTIAL_OUTPUT_DIR_NAME="output"

ENV OUTPUT_DIR="/var/local/fagi/output/"
ENV TARGET_MODE="AA_MODE" TARGET_ID="ab" TARGET_FUSED_NAME="fused" TARGET_REMAINING_NAME="remaining" TARGET_REVIEW_NAME="review" TARGET_STATS_NAME="stats"

#
# Define command
#

RUN chmod +x run-fagi-merger.sh
CMD ["./run-fagi-merger.sh"]

