#!/bin/sh
#  Copyright (c) 2017, F5 Networks, Inc.
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  *
#  http://www.apache.org/licenses/LICENSE-2.0
#  *
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
#  either express or implied. See the License for the specific
#  language governing permissions and limitations under the License.

if [ -f "/mnt/ssl-cert/identity.pkcs12" ] && [ -f "/mnt/ssl-cert/identity.pwd" ]; then
	#
	# Create OpenSSL Cert: openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
	# Convert to PKCS12  : openssl pkcs12 -export -in cert.pem -inkey key.pem -out idenity.pkcs12 -name "sitename"
	#
   keytool -keystore /etc/keystore.jks -delete -alias sitename -storepass $(cat /etc/keystore.pwd)
   keytool -importkeystore -destkeystore /etc/keystore.jks -deststorepass $(cat /etc/keystore.pwd) -srckeystore /mnt/ssl-cert/identity.pkcs12 -srcstoretype PKCS12 -srcstorepass $(cat /mnt/ssl-cert/identity.pwd) -noprompt
fi
