#!/bin/bash

# print 'git branch' on all repos, one line per repo for easier awk-ing.
# print is done only if there is merge to master

# Example: $0 devl_cblr1640

set -e
set -u

CYCLE=${1}
BRANCH=devl_${1,,}

source "$(dirname $0)/functions_git"

for repo in $(ls); do
	if [[ ! ${repo} =~ ".dtd" && ! ${repo} =~ ".sh" ]]; then

		cd $repo
		branches=$(branches_all)

		for branch in ${branches[*]}; do

			if [[ $branch == $BRANCH ]]; then

				diff=$(git diff --raw master ${BRANCH})

				if [[ ! -z "${diff}" ]]; then
					echo ${repo} ${branches[*]}
				fi
			fi
		done	
		cd ..
	fi
done
