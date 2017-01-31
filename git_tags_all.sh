#!/bin/bash

# print ${repo_name} ${tags[*]}, each on one line

set -e
set -u

repos_dir=${PWD}

for dir in $(find -maxdepth 2); do

	if [[ -e "${dir}/.git" ]]; then

		repo=$dir

		if [[ ! ${repo} =~ ".dtd" && ! ${repo} =~ ".sh" && ! ${repo} =~ "README" ]]; then
			cd $repo
			tags=$(git tag | sed 's/\n//' )
			echo $repo ${tags[*]}
			cd $repos_dir
		fi
	fi
done
