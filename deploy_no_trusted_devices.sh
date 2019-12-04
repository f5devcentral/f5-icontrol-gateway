#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

cd $DIR

docker build -f Dockerfile_no_trusted_devices -t f5-icontrol-gateway-no-trusted-devices .
docker run --name f5-icontrol-gateway-no-trusted-devices --rm -p 8443:443 f5-icontrol-gateway-no-trusted-devices
