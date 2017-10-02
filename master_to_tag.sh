#!/bin/bash

# create (move) master to tag $1 and push it to rel repo for single repo $REPO
# e.g $0 CBLR1640 cs.rdf
# exit if master is on "${TAG}_PREPROD"
# e.g $0 master_to_tag.sh CBLS1750_TI_RHEL7_PREPROD /local/git/repos/CBLS1750_TI_RHEL7_PREPROD/cs.rts

set -e
set -u

TAG=$1
repo=$2
TAG_PREPROD="${TAG}_PREPROD"
REL=https://github.deutsche-boerse.de/rel

if [[ ! -d ${repo} ]]; then
	echo "Repo ${repo} does not exist"
	exit 1
fi

exit_if_preprod() {

	# check for PREPROD tags
	TAGS=$(git tag | sed 's/\n//' )
	if [[ "${TAGS[@]}" =~ "${TAG_PREPROD}" ]]; then
		rev_preprod=$(git rev-parse $TAG_PREPROD)
		rev_master=$(git rev-parse master)

		# master is on PREPROD => return 1
		if [[ "${rev_preprod}" == "${rev_master}" ]]; then
			echo "$(basename $0): $TAG_PREPROD exissts => nothing done."
			exit 1
		fi
	fi
}

cd $repo
if [[ ! "${TAG}" == *PREPROD ]]; then
	exit_if_preprod
fi

REPO_NAME="${repo##*\/}"

git checkout ${TAG}
git branch -f master
echo 'Pushing master to scm_repo'
git push -f $REL/$REPO_NAME master

# Set sync status against master 
set_sync.pl --repo "${PWD}" --verbose --tag_impl "${TAG}"

echo
echo "$(basename $0): All done"
