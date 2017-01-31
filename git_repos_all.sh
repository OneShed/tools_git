#!/bin/bash

# List all git repos in $PWD 
# e.g. $0

set -e
set -u

repos_dir=${PWD}

for dir in $(find -maxdepth 2 -type d); do

	if [[ -e "${dir}/.git" ]]; then

		repo=$dir
		echo ${repo}
	fi
done
