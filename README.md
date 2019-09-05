# Description
This container provides the platform for running nginx unit applications
with access to a running iControl REST java stack process.

It contains a sample nginx unit applicaiton f5-icontrol-trusted-devices
which is a swagger 'schema first' application which provided management
of iControl REST device trusts as well as a proxy endpoint to serve
device trust tokens or proxy iControl REST requests to remote iControl
REST enabled devices.

The Swagger UI explore for the f5-icontrol-trusted-devices application is
available via an nginx redirect on the '/' path of the container.

# Docker Commands
## Build
    $ docker build -t rest-container .

## List Images
    $ docker images

## Run (start.sh)
    $ docker run --name rest_container --rm -d -p 8443:443 rest-container

## Authentication, Authorization, RBAC
This container runs nginx as the default web listener. The default /etc/nginx configurations
implement BASIC authentication with user 'admin' with password 'admin'. To implement an
alternative authentication, authorization, or RBAC scheme, you can volume mount the /etc/nginx
directory with your own set of nginx configurations. There is a whole book you can read
about runing nginx as an API security gateway... go read it!

### Start and stop daemon services
Shell into container

Container currently has 3 services: nginx, restjavad, unit
    $ sv status 
    $ sv up <service name> 
    $ sv down <service name>


## Docker cleanup
Remove all stopped containers: docker rm $(docker ps -a -q)
Remove all untagged images: docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
