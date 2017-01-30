#!/bin/bash

# print 'git branch' on all repos

set -e
set -u

for repo in $(ls); do
	if [[ ! ${repo} =~ ".dtd" && ! ${repo} =~ ".sh" ]]; then
		echo $repo
		cd $repo
		git branch
		cd ..
	fi
done
