#!/bin/bash

## merge_branch.sh 
# for each repo in directory, merge the branch $1 to master, if $1 exits in
# repo

# usage: $0 devl_cblr1640

set -e
set -u

BRANCH=${1}
SCRIPTS_DIR=$(dirname $0)

repos=$(${SCRIPTS_DIR}/git_branches_all.sh | grep ${BRANCH} | awk '{print $1}')

# TODO ignore PREPROD

for repo in ${repos[*]}; do
    cd $repo
    echo "Merging ${BRANCH} to master in repo $PWD"
    git checkout master
    git merge ${BRANCH}
    cd ..
done
