#!/usr/local/bin/python3

import googleapiclient.discovery
from optparse import OptionParser
import os

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
        if gcloud_instance_name.endswith("app"):
            inventory_template["app"] = {"hosts": [gcloud_instance_nat_ip]}
        elif gcloud_instance_name.endswith("db"):
            inventory_template["db"] = {"hosts": [gcloud_instance_nat_ip]}

inventory_template["_meta"] = {"hostvars": {}}
print(inventory_template)
