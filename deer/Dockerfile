FROM openjdk:9-jdk

ENV DEER_VERSION "1.0.2"

RUN mkdir /usr/local/deer /var/local/deer
WORKDIR /usr/local/deer

COPY deer/deer-cli/target/deer-cli-${DEER_VERSION}.jar ./

#
# Define environment
#

ENV JAVA_XX_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap" JAVA_MEM_OPTS="-Xmx1536m -Xms256m"

ENV CONFIG_FILE="/var/local/deer/config.ttl"

ENV OUTPUT_DIR "/var/local/deer/output/"


#
# Define entrypoint
#

COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh
CMD ["./docker-entrypoint.sh"]
