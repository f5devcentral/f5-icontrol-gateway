#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

cd $DIR

docker build -f Dockerfile_no_trusted_devices -t f5-icontrol-gateway-no-trusted-devices .
docker run --name f5-icontrol-gateway-no-trusted-devices --rm -d -p 8443:443 f5-icontrol-gateway-no-trusted-devices

if [ -n "$XDG_RUNTIME_DIR" ]
then
   echo "opening browser with xdg-open"
   sleep 2
   xdg-open "https://localhost:8443/mgmt/shared/echo"
else
   echo "available on https://localhost:8443/mgmt/shared/echo"
fi

docker attach f5-icontrol-gateway-no-trusted-devices