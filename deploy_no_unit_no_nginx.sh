#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

cd $DIR

docker build -f Dockerfile_no_unit_no_nginx -t f5-icontrol-gateway-no-nginx .
docker run --name f5-icontrol-gateway-no-nginx --rm -d -p 8105:8105 f5-icontrol-gateway-no-nginx

if [ -n "$XDG_RUNTIME_DIR" ]
then
   echo "opening browser with xdg-open"
   sleep 2
   xdg-open "http://localhost:8105"
else
   echo "available on http://localhost:8105"
fi

docker attach f5-icontrol-gateway-no-nginx
 