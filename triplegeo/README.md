## README - Docker image for Triplegeo

### Build

Build image:

    docker build -t local/triplegeo:1.2 .

### Examples

Transform a SHAPEFILE `points.shp` (with accompanying `prj`, `dbf`, `shx` files) to triplets. Run container 
by bind-mounting the proper input/output volumes:

    docker run -t --rm \
        --name triplegeo-1 \
        --volume "$(pwd)/samples/shapefile/1/options.conf:/var/local/triplegeo/options.conf:ro" \
        --volume "$(pwd)/samples/shapefile/1/input:/var/local/triplegeo/input:rw" -e INPUT_FILE=/var/local/triplegeo/input/points.shp \
        --volume "$(pwd)/samples/shapefile/1/output:/var/local/triplegeo/output:rw" \
        --tmpfs /tmp:size=128M 
        local/triplegeo:1.2

