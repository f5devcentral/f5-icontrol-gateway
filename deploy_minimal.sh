#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

cd $DIR

docker build -f Dockerfile_minimal -t f5-icontrol-gateway-minimal .
docker run --name f5-icontrol-gateway-minimal --rm -d -p 8443:443 f5-icontrol-gateway-minimal
 
if [ -n "$XDG_RUNTIME_DIR" ]
then
   echo "opening browser with xdg-open"
   sleep 2
   xdg-open "https://localhost:8443/config"
else
   echo "available on https://localhost:8443/config"
fi

docker attach f5-icontrol-gateway-minimal
