#!/bin/bash

# create (move) master to tag $1 and push it to rel repo for all repos in PWD
# e.g $0 CBLR1640

set -e
set -u

TAG=$1
repos_dir=${PWD}
REL=https://github.deutsche-boerse.de/rel

for dir in $(find -maxdepth 2 -type d | egrep -v './PROD|./CFM_TEST'); do

	if [[ -e "${dir}/.git" ]] ; then

		repo=$dir
		cd $repo
		tags=$(git tag | sed 's/\n//' )

		for tag in ${tags[*]}; do
			if [[ ${tag} == ${TAG} ]]; then
				echo Repo: $dir
				git checkout ${TAG}
				git branch -f master
				echo 'Pushing master to scm_repo'
				repo=$(echo $repo | sed -e 's/^\.\///' -e 's/^.*\///')
				git push -f $REL/$repo master

				break
			fi
		done
		cd $repos_dir
	fi
done

echo "$(basename $0): All done"
