#! /usr/bin/env python
from deepmerge import always_merger
import glob
import urllib2
import json

configuration = {}

for cf in sorted(glob.glob('/etc/unit/*.conf')):
    with open(cf) as json_file:
        data = json.load(json_file)
        configuration = always_merger.merge(configuration, data)

jsonconfig = json.dumps(configuration, indent=4, sort_keys=True)
print('merged configuraion:')
print(jsonconfig)
request = urllib2.Request(url='http://localhost:8101/config/', data=jsonconfig)
request.add_header('Content-Type', 'application/json')
request.get_method = lambda: 'PUT'
response = urllib2.urlopen(request)
print('resp: %s' % response.read())
