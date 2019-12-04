#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

cd $DIR

docker build -t f5-icontrol-gateway .
docker run --name f5-icontrol-gateway --rm -d -p 8443:443 f5-icontrol-gateway

if [ -n "$XDG_RUNTIME_DIR" ]
then
   echo "opening browser with xdg-open"
   sleep 2
   xdg-open "https://localhost:8443"
else
   echo "available on https://localhost:8443"
fi

docker attach f5-icontrol-gateway
 