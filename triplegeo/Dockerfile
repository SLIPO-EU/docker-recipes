FROM openjdk:8-jdk

ENV TRIPLEGEO_VERSION "1.2-SNAPSHOT"

ENV JAVA_XX_OPTS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
ENV JAVA_MEM_OPTS "-Xmx256m -Xms64m"

RUN apt-get update && apt-get install -y maven

WORKDIR /usr/local/triplegeo/

COPY triplegeo ./

RUN mvn package

RUN mkdir /var/local/triplegeo

ENV CONFIG_FILE "/var/local/triplegeo/options.conf"

# Specify an input file (override configuration file)
ENV INPUT_FILE ""
#ENV INPUT_FILE "/var/local/triplegeo/input/points.shp"

# Specify an output directory (override configuration file) 
ENV OUTPUT_DIR ""
#ENV OUTPUT_DIR "/var/local/triplegeo/output/"

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
