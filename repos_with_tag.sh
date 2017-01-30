#!/bin/bash

# print all repos that have tag $1

set -e
set -u

TAG=$1
repos_dir=${PWD}

for dir in $(find -maxdepth 2); do

	if [[ -e "${dir}/.git" ]]; then

		repo=$dir

		if [[ ! ${repo} =~ ".dtd" && ! ${repo} =~ ".sh" && ! ${repo} =~ "README" ]]; then
			cd $repo
			tags=$(git tag | sed 's/\n//' )
			cd $repos_dir

			for tag in ${tags[*]}; do
				if [[ ${tag} == ${TAG} ]]; then
					echo $repo
					break
				fi
			done
		fi
	fi
done
