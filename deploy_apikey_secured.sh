#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

cd $DIR

if [ -z $X_API_KEY ]
then
    echo "Please export the X_API_KEY environment variable"
    exit 1
fi

docker build -f Dockerfile_full_apikey -t f5-icontrol-gateway-apikey-secured .
docker run --name f5-icontrol-gateway-apikey-secured --rm -d -p 8443:443 -e X_API_KEY=$X_API_KEY f5-icontrol-gateway-apikey-secured

if [ -n "$XDG_RUNTIME_DIR" ]
then
   echo "opening browser with xdg-open"
   sleep 2
   xdg-open "https://localhost:8443"
else
   echo "available on https://localhost:8443"
fi

docker attach f5-icontrol-gateway-apikey-secured
