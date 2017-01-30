#!/bin/bash

# create (move) master to tag $1 and push it to rel repo for single repo $REPO
# e.g $0 CBLR1640 cs.rdf

set -e
set -u

TAG=$1
repo=$2
REL=https://github.deutsche-boerse.de/rel

if [[ ! -d ${repo} ]]; then
	echo "Repo ${repo} does not exits"
	exit 1
fi

cd $repo
git checkout ${TAG}
git branch -f master
echo 'Pushing master to scm_repo'
git push -f $REL/$repo master

echo "$(basename $0): All done"
