#!/bin/bash

## merge_branch_all.sh <CYCLE>

# Merge the CYCLE branch to master and rename the branch to $branch_closed.
# sync with other cycle branches.
# Prompt user to do the commit. No automatic merging is done.
# If merge conflict, ask user to resolve it.
#
# To be run within the root directory of git repos to-be-merged.
# Note that the script will not create new commits, but will prompt user to do
# so.

# Example: $0 CBLR1720 REPO1 REPO2 # REPO1 and REPO2 will be skipped

set -e
set -u
#set -x

TOOLS_DIR="/local/git/scm/tools_git"
# source from the script's directory
source "$TOOLS_DIR/functions_git"

PARAMS=$*
CYCLE_BRANCH="devl_${1,,}"
REPOS_SKIPPED=${*:2}

if [[ ! -n $REPOS_SKIPPED ]]; then
    echo "No repos to be skipped"
else
    echo "Repo(s) to be skipped: $REPOS_SKIPPED"
fi

# Repos with $CYCLE_BRANCH
repos=$( $TOOLS_DIR/git_branches_all.sh | grep -e "${CYCLE_BRANCH} "  \
    -e "${CYCLE_BRANCH}$" | awk '{print $1}')

merge_branch()
{
    branch_to_merge="${1:-}"
    shift
    params="${*:-}"

    if [ -z "${branch_to_merge}" ]; then
        exit_error "Error: Specify the branch to merge."
    fi

    if ! git merge $params "${branch_to_merge}" \
        -m "Merged by $(basename $0)"; then

    echo "Please resolve the merge manually." 2>&1
    echo "Hint git mergetool, git commit." 2>&1
    echo "Git branch -m $branch ${branch_to_merge}_closed" 
    exit 1;
fi
}

# return true if branch belongs to live cycle, false otherwise.
is_live() {

    cycle_branch="${1}"

    live_cycles=$($TOOLS_DIR/live_cycles_amadeus.pl)

    for lc in ${live_cycles}; do
        branch=devl_${lc,,}
        if [[ "$branch" == "$cycle_branch" ]]; then
            return
        fi
    done
    return 1
}

for repo in ${repos[*]}; do
    cd $repo

    if [[ "${REPOS_SKIPPED[*]}" =~ "$repo" ]]; then
        echo "Skipping repo $repo"
        continue
    fi

    # merge $CYCLE_BRANCH to master first
    echo "Merging ${CYCLE_BRANCH} to master in repo ${repo}."
    git checkout master
    out=$(merge_branch "${CYCLE_BRANCH}" --no-commit)
    echo $out

    # Push the new master to remotes
    git push origin master
    git push scm_repo master

    if [[ "${out}" == *stopped* ]]; then
        echo 'Stopping'
        exit 1
    fi
    # rename the merged branch to $branch_closed
    echo "Renaming ${CYCLE_BRANCH} to ${CYCLE_BRANCH}_closed."
    git branch -m "${CYCLE_BRANCH}" "${CYCLE_BRANCH}"_closed

    # merge master to other cycle's branches
    branches=$(branches_all)

    for branch in ${branches[*]}; do
        if [[ $branch != 'master' && $branch != "${CYCLE_BRANCH}" && $branch != *_closed ]]; then

            if ! is_live $branch; then
                continue
            fi

            echo "Merging master to $branch."
            git checkout $branch
            out=$(merge_branch master --no-ff)
            echo $out

            if [[ "${out}" == *stopped* ]]; then
                echo 'Stopping'
                exit 1
            fi

        fi
    done
    cd ..
done

echo "$(basename $0): All done"
