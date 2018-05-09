## README - Docker image for Triplegeo

### Build

Install 3rd-party JARs (needed by Triplegeo) into local Maven repository:

    mvn install:install-file -Dfile="$(pwd)/triplegeo/lib/RML-Mapper.jar" -DgroupId=be.ugent.mmlab.rml -DartifactId=rml-mapper -Dversion=0.3 -Dpackaging=jar

Package and install Triplegeo along with dependencies (database drivers are packaged as a Maven submodule):

    mvn install

Build image:

    docker build -t local/triplegeo:1.4 .

### Examples

#### Example: Reading from a SHAPEFILE (SHP)

Transform a SHAPEFILE `points.shp` (with accompanying `prj`, `dbf`, `shx` files) to triplets. Run container 
by bind-mounting the proper input/output volumes:

    docker run -t --rm --name triplegeo-1 \
        --volume "$(pwd)/samples/shapefile/1/options.conf:/var/local/triplegeo/options.conf:ro" \
        --volume "$(pwd)/samples/shapefile/1/mappings.yml:/var/local/triplegeo/mappings.yml:ro" \
        --volume "$(pwd)/samples/shapefile/1/classification.csv:/var/local/triplegeo/classification.csv:ro" \
        --volume "$(pwd)/samples/shapefile/1/input:/var/local/triplegeo/input:rw" \
        --volume "$(pwd)/volumes/shapefile/1/output:/var/local/triplegeo/output:rw" \
        --env INPUT_FILE=/var/local/triplegeo/input/points.shp \
        --tmpfs /tmp:size=128M 
        local/triplegeo:1.4

#### Example: Reading from a plain CSV file

Transform a group of CSV files (given as a colon-separated string) to triplets. Each input file
generates a corresponding output file (e.g for `TTL` serialization, `foo.csv` generates `foo.ttl`).

    docker run -t --name triplegeo-1 \
        --volume "$(pwd)/samples/csv/1/options.conf:/var/local/triplegeo/options.conf:ro" \
        --volume "$(pwd)/samples/csv/1/mappings.yml:/var/local/triplegeo/mappings.yml:ro" \
        --volume "$(pwd)/samples/csv/1/classification.csv:/var/local/triplegeo/classification.csv:ro" \
        --volume "$(pwd)/samples/csv/1/input:/var/local/triplegeo/input:ro" \
        --volume "$(pwd)/volumes/csv/1/output:/var/local/triplegeo/output" \
        --env INPUT_FILE=/var/local/triplegeo/input/part1.csv:/var/local/triplegeo/input/part2.csv:/var/local/triplegeo/input/part3.csv \
        local/triplegeo:1.4

#### Example: Reading from a database table

Transform columns of a database table to triplets. A sample table SQL dump (suitable for testing this configuration) can be found 
under `samples/jdbc/1/towns.sql.gz`.

Now, there is no `INPUT_FILE` environment variable, instead we provide all table-related configuration inside our (externally provided)
configuration file. The connection-related parameters can all be overriden by environment variables passed at runtime. Note that if a 
password is needed to connect to the database, the password file must be bind-mounted into the container.

    docker run -t --rm --name triplegeo-1 \
        --volume "$(pwd)/samples/jdbc/1/options.conf:/var/local/triplegeo/options.conf:ro" \
        --volume "$(pwd)/samples/jdbc/1/mappings.yml:/var/local/triplegeo/mappings.yml:ro" \
        --volume "$(pwd)/samples/jdbc/1/classification.csv:/var/local/triplegeo/classification.csv:ro" \
        --volume "$(pwd)/volumes/jdbc/1/output:/var/local/triplegeo/output:rw" \
        --link postgres-1:db-server
        --env DB_URL=jdbc:postgresql://db-server:5432/triplegeo-examples \
        --env DB_USERNAME=slipo \
        --volume "$(pwd)/secrets/password:/var/local/triplegeo/secrets/password:ro" \
        --env DB_PASSWORD_FILE=/var/local/triplegeo/secrets/password \
        local/triplegeo:1.4

