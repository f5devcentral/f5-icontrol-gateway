# F5 iControl Gateway Container

![f5-icontrol-gateway container](https://github.com/f5devcentral/f5-icontrol-trusted-devices/raw/master/static/images/F5iControlGatewayContainer640x360.png)

This container provides the platform for running nginx unit applications
with access to a running iControl REST java stack process.

It contains a sample nginx unit applicaiton f5-icontrol-trusted-devices
which is a swagger 'schema first' application which provided management
of iControl REST device trusts as well as a proxy endpoint to serve
device trust tokens or proxy iControl REST requests to remote iControl
REST enabled devices.

The Swagger UI explore for the f5-icontrol-trusted-devices application is
available via an nginx redirect on the '/' path of the container.

## Docker Commands

### Build

`$ docker build -t f5-icontrol-gateway .`

### List Images

`$ docker images`

### Run

`$ docker run --name f5-icontrol-gateway --rm -d -p 8443:443 f5-icontrol-gateway`

### Authentication, Authorization, RBAC

This container runs nginx as the default web listener. The default /etc/nginx configurations
implement BASIC authentication with user 'admin' with password 'admin'. To implement an
alternative authentication, authorization, or RBAC scheme, you can volume mount the /etc/nginx
directory with your own set of nginx configurations. There is a whole book you can read
about runing nginx as an API security gateway... go read it!

### Note on Publishing Orchestration Applications with the f5-icontrol-gateway

Orchestration application can take any URI namespace except for those used by restjavad and the NGINX Unit control interface.

```bash
/mgmt - Used by restjavad
/config - Used by NGINX Unit
```

If you need to overcome this limitation, because of backwards compatibility requirements, you will need to create your own NGINX configuration with more specific locations included before the NGINX locations for restjavad or NGINX Unit. Alternatively, if you desire to have your application endpoints be the ONLY reachable services from outside the container, then you can remove the externally accessible restjavad and NGINX Unit locations from the NGINX configuration completely. The services will still be started and reachable within the container on 127.0.0.1:8100 (restjavad) and 127.0.0.1:8101 (NGINX Unit control).

### Building a Container with Only Unit Externally Exposed

To build a container which only exposes the NGINX Unit published namespace, thus removing exposed access to the restjavad and NGINX Unit control interface, build a customer 'minimial' container.

`$ docker build -f Dockerfile_minimal -t f5-icontrol-gateway-minimal .`

The local container image will be named `f5-icontrol-gateway-minimal`.

### Building a Container without the TrustedDevices Application

To build a container which does not include the TrustedDevices NGINX Unit orchestration application.

`$ docker build -f Dockerfile_no_trusted_devices -t f5-icontrol-gateway-no-trusted-devices .`

The local container image will be named `f5-icontrol-gateway-no-trusted-devices`.

### Start and stop daemon services

Shell into container

Container currently has 3 services: nginx, restjavad, unit

`$ sv status`

`$ sv up <service name>`

`$ sv down <service name>`

### Docker cleanup

Remove all stopped containers:

`docker rm $(docker ps -a -q)`

Remove all untagged images:

`docker rmi $(docker images | grep "^<none>" | awk "{print $3}")`
