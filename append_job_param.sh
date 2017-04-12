#!/bin/bash
#
# edit file content using sed
#
# Usage for batch replacement in config.xml
# for f in $(find <jenkins_jobs_folder> -name 'config.xml'); do
# ./append_job_param.sh $f <param_name>; done
#
# e.g. for f in $(find /local/jenkins/jobs -name 'config.xml'); do ./append_job_param.sh $f _eepr; done

set -x

file=$1
param_name=$2
desc=
default_value=

old="<\/parameterDefinitions>"
#new="        <hudson.model.StringParameterDefinition>\n          <name>${param_name}</name>\n          <description>${desc}</description>\n          <defaultValue>${default_value}</defaultValue>\n        </hudson.model.StringParameterDefinition>\n      </parameterDefinitions>"
new="  <hudson.model.StringParameterDefinition>\n          <name>${param_name}<\/name>\n          <description>${desc}<\/description>\n          <defaultValue>${default_value}<\/defaultValue>\n        <\/hudson.model.StringParameterDefinition>\n      <\/parameterDefinitions>"
sed -i "s/$old/$new/" $1
