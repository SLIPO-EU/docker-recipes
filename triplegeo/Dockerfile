FROM openjdk:8-jdk

ENV TRIPLEGEO_VERSION "1.2-SNAPSHOT"

RUN apt-get update && apt-get install -y maven

#
# Build
#

WORKDIR /usr/local/triplegeo/

COPY triplegeo ./

# Customize POM (declare additional runtime deps)
COPY pom.xml ./pom.xml

RUN mvn package

RUN mkdir /var/local/triplegeo

#
# Define environment
#

## Enviroment for Java runtime ##

ENV JAVA_XX_OPTS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
ENV JAVA_MEM_OPTS "-Xmx256m -Xms64m"

## Environment common to all input sources ##

ENV CONFIG_FILE "/var/local/triplegeo/options.conf"

# Specify an output directory (overrides configuration file) 
ENV OUTPUT_DIR ""
#ENV OUTPUT_DIR "/var/local/triplegeo/output/"

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

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
