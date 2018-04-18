#!/bin/bash

## backout_epr.sh
# Cleanup after the EPR is backed out 
# 
# e.g $0 IFRD-UNIX IFS18401 2.00 
## 1/ Remove the release tag from local repo and rel org. If previous release
# exists, move the floating tag  back on the commit and force push it to rel.
# If no previous release, remove both tags from local and rel.
## 4/ Remove the merge issue of the application if any. 
## 5/ Re-run the sync check on the application.

set -e
set -u

dirname=$(dirname $0)
. $dirname/functions_git

APPLICATION=$1
CYCLE=$2
RELEASE=$3

REPOS_LOCAL=/local/git/repos

REL_TAG="${CYCLE}_${APPLICATION}_${RELEASE}"
repos_cmd="${dirname}/appl_repos_amadeus.pl $APPLICATION"

prev_rel() { # {{{

    # parse release version to major.minor
    major=$(echo $RELEASE | sed  's/\..*//')
    minor=$(echo $RELEASE | sed  's/.*\.//')

    # full
    if [[ "${minor}" == "00" ]]; then
        echo 'full'
        lower_major=$((--major))
        echo "${lower_major}.00"
    # fix
    else
        lower_minor=$((--minor))
        # add 0 if minor < 10 to have a 2 digit number
        if [[ ${#lower_minor} == 1 ]]; then
            lower_minor="0${lower_minor}"
        fi

        echo "${major}.${lower_minor}"
    fi
} # }}}

for repo in $($repos_cmd); do

    cd $REPOS_LOCAL/$repo
    REL=https://github.deutsche-boerse.de/rel/$repo

    if tag_local_exists $REL_TAG; then
        echo $REL_TAG exists in local repo, removing it 
        #git tag -D $REL_TAG
    else
        exit_error $REL_TAG does not exist
    fi

    if tag_remote_exists $REL_TAG $REL; then
        echo $REL_TAG exists in $REL, removing it 
        #git tag -D $REL_TAG
    else
        exit_error $REL_TAG does not exist
    fi


done
   
echo
echo "$(basename $0): All done"
