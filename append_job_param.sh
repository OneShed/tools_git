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

old="_sire=\${_sire}"
new="_sire=\${_sire}\n_eeprid=\${_eeprid}"
sed -i "s/$old/$new/" $1
