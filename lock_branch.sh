#!/bin/bash

set -e
set -u
set -x

echo "add branch protection"

repo=$1
branch=$2

curl -s -v -X PUT -H "accept: application/vnd.github.luke-cage-preview+json" -k --user scmluxadm:${SCMLUXADM_TOKEN} -i "https://github.deutsche-boerse.de/api/v3/repos/dev/$repo/branches/$branch/protection" --data '{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": null, 
  "restrictions": {
    "users": [
      "scmluxadm"
    ],
    "teams": [
      "cs-cfm-community"
    ]
  }
}'

