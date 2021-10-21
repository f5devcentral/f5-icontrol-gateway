#! /usr/bin/env python3
"""Init script for NGINX Unit"""

import glob
import socket
import json
import datetime

from deepmerge import always_merger

UNIT_CONTROL_SOCKET = '/var/run/unit/control.sock'

configuration = {}

for cf in sorted(glob.glob('/etc/unit/*.conf')):
    with open(cf) as json_file:
        data = json.load(json_file)
        configuration = always_merger.merge(configuration, data)

jsonconfig = json.dumps(configuration, indent=4, sort_keys=True)
print('[info] %s: unitinit - merged configuration: %s\n' % (datetime.datetime.now().isoformat(), jsonconfig))

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
    sock.connect(UNIT_CONTROL_SOCKET)
    message = "PUT /config HTTP/1.1\n"
    message += "Host: localhost\n"
    message += "Accept: */*\n"
    message += "Content-Type: application/json\n"
    message += "Content-Length: %s\n\n" % len(jsonconfig)
    message += jsonconfig
    sock.sendall(message.encode('utf-8'))
    res = []
    while True:
        data = sock.recv(8192)
        if not data:
            break
        res.append(data.decode('utf-8'))
    print('[info] %s: unitinit - configuration response: %s' % (datetime.datetime.now().isoformat(),''.join(res)))
except socket.error as err:
    print('[error] %s: unitinit - error writing to unit control socket: %s' % (datetime.datetime.now().isoformat(), err))
finally:
    sock.close()
