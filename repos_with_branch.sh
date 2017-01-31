#!/bin/bash

# print all repos that have branch $1

set -e
set -u

BRANCH=$1
repos_dir=${PWD}

for dir in $(find -maxdepth 2 -type d); do

	if [[ -e "${dir}/.git" ]]; then

		repo=$dir

		cd $repo
		branches=$(git branch | sed 's/\n//' | sed 's/^*//')
		cd $repos_dir

		for branch in ${branches[*]}; do
			if [[ ${branch} == ${BRANCH} ]]; then
				echo $repo
				break
			fi
		done
	fi
done
