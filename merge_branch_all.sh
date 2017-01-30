#!/bin/bash

## merge_branch_all.sh <CYCLE>

# Merge the CYCLE branch to master and rename the branch to $branch_closed.
# sync with other cycle branches.
# Prompt user to do the commit. No automatic merging is done.
# If merge conflict, ask user to resolve it.
# 
# To be run within the root directory of git repos to-be-merged.

# Example: $0 CBLR1720

set -e
set -u

# source from the script's directory
source "$(dirname $0)/functions_git"

CYCLE_BRANCH="devl_${1,,}"
DIR="$(dirname $0)"

# Repos with $CYCLE_BRANCH
repos=$( $DIR/git_branches_all.sh | grep -e "${CYCLE_BRANCH} "  \
	-e "${CYCLE_BRANCH}$" | awk '{print $1}')

merge_branch()
{
	branch_to_merge="${1:-}"
	if [ -z "${branch_to_merge}" ]; then
		exit_error "Specify the branch to merge."
	fi
	repo="${2:-}"

	if ! git merge --no-commit "${branch_to_merge}" \
	       	-m "Merged by $(basename $0)"; then

		echo "Hint git mergetool, git commit." 2>&1
		exit 1;
	fi
}

for repo in ${repos[*]}; do
	cd $repo

	# merge $CYCLE_BRANCH to master first
	echo "Merging ${CYCLE_BRANCH} to master in repo ${repo}."
	git checkout master
	merge_branch "${CYCLE_BRANCH}"

	# rename the merged branch to $branch_closed
	echo "Renaming ${CYCLE_BRANCH} to ${CYCLE_BRANCH}_closed."
	git branch -m "${CYCLE_BRANCH}" "${CYCLE_BRANCH}"_closed

	# merge master to other cycle's branches
	branches=$(branches_all)

	for branch in ${branches[*]}; do
		if [[ $branch != 'master' && $branch != "${CYCLE_BRANCH}" && $branch != "_closed$" ]]; then
			echo "Merging master to $branch."
			git checkout $branch
			merge_branch master
		fi
	done
	cd ..
done

echo "$(basename $0): All done"
