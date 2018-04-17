FROM openjdk:8-jdk

ENV TRIPLEGEO_VERSION "1.4"

RUN mkdir /var/local/triplegeo /usr/local/triplegeo /usr/local/triplegeo/lib

WORKDIR /usr/local/triplegeo/

COPY triplegeo/target/lib/ database-drivers/target/dependency/ ./lib/
COPY triplegeo/target/triplegeo-1.4-SNAPSHOT.jar ./triplegeo.jar

#
# Define environment
#

## Enviroment for Java runtime ##

ENV JAVA_XX_OPTS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
ENV JAVA_MEM_OPTS "-Xmx512m -Xms64m"

## Environment common to all input sources ##

ENV CONFIG_FILE "/var/local/triplegeo/options.conf"
ENV MAPPING_FILE "/var/local/triplegeo/mappings.yml"
ENV CLASSIFICATION_FILE "/var/local/triplegeo/classification.csv"

# Specify an output directory (overrides configuration file) 
ENV OUTPUT_DIR "/var/local/triplegeo/output/"

## Environment for file-based input ##

# Specify an input file or a colon-separated list of files (overrides configuration file).
# Note that these files must correspond to container-local existing file paths.
#ENV INPUT_FILE "/var/local/triplegeo/input/points-1.shp:/var/local/triplegeo/input/points-2.shp"
ENV INPUT_FILE ""

## Environment for table-based input ##

# Specify a connection URL for a JDBC database (overrides configuration file).
#ENV DB_URL "jdbc:postgresql://db-server:5432/triplegeo"
ENV DB_URL ""

# Specify a database user to connect as
ENV DB_USERNAME ""

# Specify a container-local file that stores the database password.
ENV DB_PASSWORD_FILE "" 

#
# Define entrypoint
#

COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh
CMD ["./docker-entrypoint.sh"]
