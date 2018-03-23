## README - Docker image for Triplegeo

### Build

Package triplegeo tool along with dependencies (database drivers are packaged as a Maven submodule):

    mvn package

Build image:

    docker build -t local/triplegeo:1.2 .

### Examples

#### Example: Reading from a SHAPEFILE (SHP)

Transform a SHAPEFILE `points.shp` (with accompanying `prj`, `dbf`, `shx` files) to triplets. Run container 
by bind-mounting the proper input/output volumes:

    docker run -t --rm \
        --name triplegeo-1 \
        --volume "$(pwd)/samples/shapefile/1/options.conf:/var/local/triplegeo/options.conf:ro" \
        --volume "$(pwd)/samples/shapefile/1/input:/var/local/triplegeo/input:rw" \
        --env INPUT_FILE=/var/local/triplegeo/input/points.shp \
        --volume "$(pwd)/samples/shapefile/1/output:/var/local/triplegeo/output:rw" \
        --tmpfs /tmp:size=128M 
        local/triplegeo:1.2

#### Example: Reading from a plain CSV file

Transform a group of CSV files (given as a colon-separated string) `osm_pois_part*.csv` to triplets. Each input
file generates a corresponding output file (e.g for `TTL` serialization, that would be `osm_pois_part*.ttl`).
    
    docker run -t --rm \
        --name triplegeo-1 \
        --volume "$(pwd)/samples/csv/1/options.conf:/var/local/triplegeo/options.conf:ro" \
        --volume "$(pwd)/samples/csv/1/input:/var/local/triplegeo/input:ro" \
        --env INPUT_FILE=/var/local/triplegeo/input/osm_pois_part1.csv:/var/local/triplegeo/input/osm_pois_part2.csv:/var/local/triplegeo/input/osm_pois_part3.csv \
        --volume "$(pwd)/samples/csv/1/output:/var/local/triplegeo/output:rw" \
        local/triplegeo:1.2

#### Example: Reading from a database table

Transform columns of a database table to triplets. A sample table SQL dump (suitable for testing this configuration) can be found 
under `samples/jdbc/1/towns.sql.gz`.

Now, there is no `INPUT_FILE` environment variable, instead we provide all table-related configuration inside our (externally provided)
configuration file. The connection-related parameters can all be overriden by environment variables passed at runtime. Note that if a 
password is needed to connect to the database, the password file must be bind-mounted into the container.

    docker run -t --rm \
        --name triplegeo-1 \
        --volume "$(pwd)/samples/jdbc/1/options.conf:/var/local/triplegeo/options.conf:ro" \
        --volume "$(pwd)/samples/jdbc/1/output:/var/local/triplegeo/output:rw" \
        --link postgres-1:db-server
        --env DB_URL=jdbc:postgresql://db-server:5432/triplegeo-examples \
        --env DB_USERNAME=slipo \
        --volume "$(pwd)/secrets/password:/var/local/triplegeo/secrets/password:ro" \
        --env DB_PASSWORD_FILE=/var/local/triplegeo/secrets/password \
        local/triplegeo:1.2

