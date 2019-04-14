FROM openjdk:9-jdk

ENV DEER_VERSION "2.0.1"
ENV DEER_SLIPO_PLUGIN_VERSION "1.0.0"

RUN mkdir /usr/local/deer /usr/local/deer/plugins /var/local/deer /var/local/deer/input /var/local/deer/output
WORKDIR /var/local/deer

COPY deer/deer-cli/target/deer-cli-${DEER_VERSION}.jar heap-size-funcs.sh /usr/local/deer/
COPY deer-slipo-plugin/target/deer-slipo-plugin-${DEER_SLIPO_PLUGIN_VERSION}-plugin.jar /usr/local/deer/plugins/
RUN ln -s /usr/local/deer/plugins ./plugins

#
# Define environment
#

ENV CONFIG_FILE="/var/local/deer/config.ttl"
ENV OUTPUT_DIR="/var/local/deer/output" OUTPUT_FORMAT="N-TRIPLES" OUTPUT_NAME="enriched"
ENV INPUT_FILE="/var/local/deer/input/fused.nt"
ENV STATS_FILE="/var/local/deer/deer-analytics.json"

#
# Define entrypoint
#

COPY docker-command.sh /
RUN chmod +x /docker-command.sh
CMD ["/docker-command.sh"]
