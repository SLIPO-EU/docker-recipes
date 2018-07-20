FROM openjdk:9-jdk

ENV DEER_VERSION "1.1.3"

RUN mkdir /usr/local/deer /var/local/deer /var/local/deer/input /var/local/deer/output
WORKDIR /var/local/deer

COPY deer/deer-cli/target/deer-cli-${DEER_VERSION}.jar /usr/local/deer/

#
# Define environment
#

ENV CONFIG_FILE="config.ttl"
ENV OUTPUT_DIR="output" OUTPUT_FORMAT="N-TRIPLES"
ENV INPUT_FILE="input/1.nt"

#
# Define entrypoint
#

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]
