# -*- mode: dockerfile -*-
# vi: set ft=dockerfile :

FROM openjdk:8-jdk

ENV TRIPLEGEO_VERSION "1.5"

RUN mkdir /var/local/triplegeo /usr/local/triplegeo /usr/local/triplegeo/lib

WORKDIR /usr/local/triplegeo/

COPY triplegeo/target/lib/ ./lib/
COPY triplegeo/target/triplegeo-${TRIPLEGEO_VERSION}-SNAPSHOT.jar ./triplegeo.jar

#
# Define environment
#

ENV CONFIG_FILE "/var/local/triplegeo/options.conf"
ENV SPARQL_FILE "/var/local/triplegeo/query.sparql"

# Specify an output directory (overrides configuration file) 
ENV OUTPUT_DIR "/var/local/triplegeo/output/"
# Specify an output name (without the extension)
ENV OUTPUT_NAME "points"

# Specify an input file or a colon-separated list of files (overrides configuration file).
# Note that these files must correspond to container-local existing file paths.
#ENV INPUT_FILE "/var/local/triplegeo/input/classification.nt:/var/local/triplegeo/input/points.nt"
ENV INPUT_FILE ""


#
# Define command
#

COPY run-reverse-triplegeo.sh ./
RUN chmod +x run-reverse-triplegeo.sh
CMD ["./run-reverse-triplegeo.sh"]
