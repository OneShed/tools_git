#!/bin/bash

# print all repos that have tag $1

set -e
set -u

TAG=$1
RELEASE_TAG="${2:-}"
repos_dir=${PWD}

tools=/local/git/scm/tools_git

repos=
if [[ ! -z $RELEASE_TAG ]]; then
    echo Searching for release tag $TAG
    repos=$(find -maxdepth 2 -type d | egrep -v './PROD|./CFM_TEST');
else

    # ignore directories of unrelated cycle
    echo Searching for cycle tag $TAG
    repos_nodep=$(find -maxdepth 1 -type d | egrep '[a-z]')
    tag_repos=$(find $TAG -maxdepth 1 -type d | egrep -v ^${TAG}$ || true)
    repos=( "${repos_nodep[*]}" "${tag_repos[*]}" )
fi

for dir in ${repos[*]}; do

	if [[ -e "${dir}/.git" ]]; then

		repo=$dir

		if [[ ! ${repo} =~ ".dtd" && ! ${repo} =~ ".sh" && ! ${repo} =~ "README" ]]; then
			cd $repo
			tags=$(git tag | sed 's/\n//' )
			cd $repos_dir

			for tag in ${tags[*]}; do
				if [[ ${tag} == ${TAG} ]]; then
                    reponame=$(echo $repo | sed 's/^.*\///')
                    apps=$($tools/repo_appl_amadeus.pl dev/$reponame)
					echo $repo $apps
					break
				fi
			done
		fi
	fi
done
