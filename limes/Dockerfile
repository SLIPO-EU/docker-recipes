FROM openjdk:8-jdk

ENV LIMES_VERSION "1.5.7"

RUN apt-get update && apt-get install -y xmlstarlet
RUN mkdir /var/local/limes

WORKDIR /usr/local/limes/

COPY limes-standalone.jar docker-command.sh heap-size-funcs.sh ./

#
# Define environment
#

ENV CONFIG_FILE "/var/local/limes/config.xml"

# Specify an output directory (overrides configuration file) 
ENV OUTPUT_DIR "/var/local/limes/output/"

ENV SOURCE_FILE="/var/local/limes/input/a.nt" TARGET_FILE="/var/local/limes/input/b.nt"
ENV ACCEPTED_NAME="accepted" REVIEW_NAME="review"

#
# Define command
#

RUN chmod +x docker-command.sh
CMD ["./docker-command.sh"]
