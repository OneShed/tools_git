#!/usr/bin/bash

# 1. Create a jenkins job based on /tmp/jobs file via copy of ${JOB_COPY} job with content:
# <appl_name> <repo>
# e.g
# STARGATE cs.stargate.git 
# GAF      cs.gaf.git

# 2. Update it's repo addres in the config.xml 

# Usage:
# 1/ create or update file /tmp/jobs
# 2./ bash $0

set -e
set -u 
set -x

GIT=/usr/bin/git
JOBS=/local/jenkins/jobs
JOB_COPY=PRODSUP_AMQ
FILE_JOBS=/tmp/jobs

retval='0'

function exit_error() # {{{
{
	echo "$(basename $0): ${1:-"Unknown Error"}" 1>&2
	((retval++))
} # }}}

function log_error() # {{{
{
	echo "$(basename $0): ${1:-"Unknown Error"}" 1>&2
	((++retval))

} # }}}

# copy COPYFROM to 

if [ ! -e "${FILE_JOBS}" ]; then
	exit_error "File $FILE_JOBS does not exist"
fi

while read line; do 

	application=$(echo $line | awk '{print $1}')
	repo=$(echo $line | awk '{print $2}')

	COPY_FROM="${JOBS}/${JOB_COPY}"
	if [ ! -d "${COPY_FROM}" ]; then 
		exit_error "Not found: ${COPY_FROM}"
	fi

	JOB="${JOBS}/${application}"

	if [ -d "${JOB}" ]; then
		log_error "Job ${JOB} already exists"
		continue
	fi

	# copy from current job
	cp -R "$COPY_FROM" "${JOB}"

	# remove builds directory
	if [ -d "${JOB}/builds" ]; then
		rm -rf "${JOB}/builds"
        fi	

	# update the config.xml:
	# use vim substitute
	eval "ex $JOB/config.xml <<EOF
	:%s/cs.mars_ddl/$repo/g
	:x
EOF"
	echo "Created job $JOB"

done < $FILE_JOBS 

exit $retval
