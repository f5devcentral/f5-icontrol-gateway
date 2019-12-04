#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

cd $DIR

docker build -f Dockerfile_minimal -t f5-icontrol-gateway-minimal .
docker run --name f5-icontrol-gateway-minimal --rm -p 8443:443 f5-icontrol-gateway-minimal
 