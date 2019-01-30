#!/bin/bash

set -e
set -u
set -x

echo "Curl to create Token"

repo=$1

curl -s -v -X POST -k --user scmluxadm:${SCMLUXADM_TOKEN} -i "https://github.deutsche-boerse.de/api/v3/repos/dev/$repo/hooks" --data '{
    "name": "web",
    "active": true,
    "config": {
        "url": "http://scmlux.cedelgroup.com/generic-webhook-trigger/invoke",
        "content_type": "json"
    }
}'
