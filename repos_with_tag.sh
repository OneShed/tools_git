#!/bin/bash

# print all repos that have tag $1

set -e
set -u

TAG=$1
repos_dir=${PWD}

# ignore directories of unrelated cycle
repos_nodep=$(find -maxdepth 1 -type d | egrep '[a-z]')
tag_repos=$(find $TAG -maxdepth 1 -type d | egrep -v ^${TAG}$)
repos=( "${repos_nodep[*]}" "${tag_repos[*]}" )

for dir in ${repos[*]}; do

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
