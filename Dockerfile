# multi-stage build
FROM alpine

# Add VERSION file
COPY VERSION /

# Install infrastructure - nginx, hpasswd tools from apache2-utils, 
# runit, curl to download f5 packages from artifactory, openssl to create certs  
RUN apk --update add nginx apache2-utils openjdk7-jre-base bash runit rpm curl openssl 

# Hack fix to openjdk7-jre-base where this file was left out to support SSL TLS
COPY src/sunec.jar /usr/lib/jvm/java-1.7-openjdk/jre/lib/ext/

# Add ln to specific Java7 required by F5 restjavad
RUN ln -s /usr/lib/jvm/java-1.7-openjdk/jre/bin/java /usr/bin/java7

# Install F5 restjavad packages via RPM
COPY rpms/ /root/rpms/
RUN rpm -i --nodeps /root/rpms/java/*

# Copy files explicitly so you know what you are getting
# nginx files
RUN mkdir -p /etc/service/nginx
COPY nginx/etc/nginx.conf /etc/nginx/nginx.conf
COPY nginx/etc/apigateway.conf /etc/nginx/apigateway.conf
COPY nginx/etc/auth.conf /etc/nginx/auth.conf
COPY nginx/ssl/ /etc/ssl/
COPY config/etc/service/nginx/ /etc/service/nginx/
# restjavad files
COPY config/etc/keystore.jks  /etc/keystore.jks
COPY config/etc/keystore.pwd  /etc/keystore.pwd
COPY config/etc/quartz.properties  /etc/quartz.properties
COPY config/etc/restjavad.log.conf /etc/restjavad.log.conf
COPY config/etc/rest.container.properties /etc/rest.container.properties
RUN mkdir -p /etc/service/restjavad/
COPY config/etc/service/restjavad/ /etc/service/restjavad/
# download and install unit from source
RUN apk add git alpine-sdk go godep python2 python2-dev py2-pip python3 python3-dev php7 php7-dev php7-embed nodejs nodejs-npm nodejs-dev perl perl-dev ruby ruby-dev openssl-dev openjdk11-jdk make gcc libc-dev curl
RUN npm install -g node-gyp
RUN pip2 install deepmerge
RUN mkdir -p /usr/src && \
cd /usr/src && \
git clone https://github.com/nginx/unit && \
cd /usr/src/unit && \ 
./configure --user=nginx --group=nginx --prefix=/usr --openssl --control=unix:/var/run/unit/control.sock --log=/var/log/unit.log --state=/var/run/unit --pid=/var/run/unit/unit.pid && \
./configure go --go-path=/root/go && \
./configure java && \
./configure perl && \
./configure php && \
./configure python --config=python2-config && \
./configure python --config=python3-config && \
./configure ruby && \
./configure nodejs && \
make && \
make install && \
cd / && \
rm -rf /usr/src/unit
# Clean dev libraries needed to compile
RUN apk del git alpine-sdk python2-dev python3-dev php7-dev nodejs-dev perl-dev ruby-dev openssl-dev make libc-dev curl
RUN mkdir -p /etc/service/unit
COPY config/etc/service/unit/ /etc/service/unit/
RUN mkdir -p /etc/unit
COPY config/etc/unit/01_global_listener.conf /etc/unit/
COPY config/usr/bin/unitinit.py /usr/bin/unitinit.py

# Configure runit process manager
RUN mkdir -p /etc/runit/
COPY runit/ /etc/runit/
RUN chmod +x /etc/runit/1 /etc/runit/2 /etc/runit/3 /etc/runit/boot

# Copy default certs/password
RUN mkdir -p /etc/ssl/
RUN mkdir -p /etc/www/pass
COPY src/scripts/* /scripts/
RUN chmod +x /scripts/*

# Install TrustDevice/TrustedProxy unit application
RUN mkdir -p /var/lib/f5-icontrol-trusted-devices
COPY /f5-icontrol-trusted-devices/ /var/lib/f5-icontrol-trusted-devices/
RUN chown -R nginx:nginx /var/lib/f5-icontrol-trusted-devices
RUN ln -s /usr/lib/node_modules/unit-http /var/lib/f5-icontrol-trusted-devices/node_modules/unit-http
RUN chmod +x /var/lib/f5-icontrol-trusted-devices/unitapp.js
RUN mkdir /sshkeys
RUN chown nginx:nginx /sshkeys

# Cleanup
RUN rm -fr /root/rpms/
RUN rm /etc/nginx/conf.d/default.conf

VOLUME /etc/nginx

EXPOSE 443

ENTRYPOINT ["/etc/runit/boot"]
