#! /usr/bin/env python
from deepmerge import always_merger
import glob
import socket
import json

UNIT_CONTROL_SOCKET = '/var/run/unit/control.sock'

configuration = {}

for cf in sorted(glob.glob('/etc/unit/*.conf')):
    with open(cf) as json_file:
        data = json.load(json_file)
        configuration = always_merger.merge(configuration, data)

jsonconfig = json.dumps(configuration, indent=4, sort_keys=True)
print('merged configuraion:')
print(jsonconfig)

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
    sock.connect(UNIT_CONTROL_SOCKET)
    message = "PUT /config HTTP/1.1\n"
    message += "Host: localhost\n"
    message += "Accept: */*\n"
    message += "Content-Type: application/json\n"
    message += "Content-Length: %s\n\n" % len(jsonconfig)
    message += jsonconfig
    sock.sendall(message)
    res = [];
    while True:
        data = sock.recv(8192)
        if not data:
            break
        res.append(data)
    print('configuration response: %s' % ''.join(res))
except socket.error as err:
    print('error writing to unit control socket: %s' % err)
finally:
    sock.close()
