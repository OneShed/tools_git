#!/bin/bash

# print branches which are not _closed 

set -e
set -u

for repo in $(ls); do
	if [[ ! ${repo} =~ ".dtd" && ! ${repo} =~ ".sh" ]]; then
		cd $repo
        if branches=$(git branch | egrep -v "_closed|master"); then
            echo $repo
            echo $branches
            echo 
            branches=''
        fi 
		cd ..
	fi
done
