#!/usr/local/bin/python3

import googleapiclient.discovery
from optparse import OptionParser
import os

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/Users/4rren/git/otus/temp/Infra-03dfcbb34e63.json"
os.environ["GOOGLE_COMPUTE_PROJECT"] = "infra-226519"
os.environ["GOOGLE_COMPUTE_ZONE"] = "europe-west1-b"

gce_project = os.environ.get("GOOGLE_COMPUTE_PROJECT")
gce_zone = os.environ.get("GOOGLE_COMPUTE_ZONE")

parser = OptionParser()
parser.add_option('--list', action="store_true", dest='return_list')

(options, arguments) = parser.parse_args()

inventory_template = {}

compute = googleapiclient.discovery.build('compute', 'v1')

result = compute.instances().list(project=gce_project, zone=gce_zone).execute()

if options.return_list:
    for i in result.get("items"):
        gcloud_instance_name = i.get("name")
        gcloud_instance_nat_ip = i.get("networkInterfaces")[0].get("accessConfigs")[0].get('natIP')
        inventory_template[gcloud_instance_name] = {"hosts": [gcloud_instance_nat_ip]}

inventory_template["_meta"] = {"hostvars": {}}
print(inventory_template)
