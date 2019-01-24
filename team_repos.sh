#!/bin/bash

set -e
set -u

team_id=$1 # 441 dev/ifs-devops, 103 rel/SCM Luxembourg

curl -L -s -u scmluxadm:$SCMLUXADM_TOKEN -X GET -H "Accept: application/vnd.github.hellcat-preview+json" -H "Content-Type: application/json" $GITHUB/api/v3/teams/$team_id/repos | egrep '^\s{4}\"name\":' | awk  '{print $2}' | sed 's/\"//g' | sed 's/,//g'
