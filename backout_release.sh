#!/bin/bash

## backout_epr.sh
# Cleanup after the EPR is backed out
#
# e.g $0 IFRD-UNIX IFS18401 2.00
## 1/ Remove the release tag from local repo and rel org. If previous release
# exists, move the floating tag  back on the commit and force push it to rel.
# If no previous release, remove both tags from local and rel.
## 2/ Remove the merge issue of the application if any.
## 3/ Re-run the sync check on the application.
## 4/ Remove tar from release area

set -e
set -u
# set -x

dirname=$(dirname $0)
. $dirname/functions_git

APPLICATION=$1
CYCLE=$2
RELEASE=$3

REPOS_LOCAL=/local/git/repos
REPOS_CONF=/etc/cs.migration_scripts/repos.conf


REL_TAG="${CYCLE}_${APPLICATION}_${RELEASE}"
CYCLE_TAG="${CYCLE}"
repos_cmd="${dirname}/appl_repos_amadeus.pl $APPLICATION"

#debug="echo"
debug=""

prev_rel() { # {{{

    # parse release version to major.minor
    major=$(echo $RELEASE | sed  's/\..*//')
    minor=$(echo $RELEASE | sed  's/.*\.//')

    # full
    if [[ "${minor}" == "00" ]]; then
        lower_major=$((--major))
        echo "${CYCLE}_${APPLICATION}_${lower_major}.00"
        # fix
    else
        lower_minor=$((--minor))
        # add 0 if minor < 10 to have a 2 digit number
        if [[ ${#lower_minor} == 1 ]]; then
            lower_minor="0${lower_minor}"
        fi
        echo "${CYCLE}_${APPLICATION}_${major}.${lower_minor}"
    fi
} # }}}

for repo in $($repos_cmd); do

    REL=https://github.deutsche-boerse.de/rel/$repo

    # if repo with dependency check for the release tag
    if [[ -d $REPOS_LOCAL/$repo ]]; then
        cd $REPOS_LOCAL/$repo

        if ! tag_local_exists $REL_TAG; then
            if [[ -d $REPOS_LOCAL/$CYCLE/$repo ]]; then
                cd $REPOS_LOCAL/$CYCLE/$repo 

                if ! tag_local_exists $REL_TAG; then
                    exit_error $REL_TAG does not exist in ${PWD}
                fi
            else
                exit_error $REL_TAG does not exist in $REPOS_LOCAL/$repo
            fi
        fi
    fi

    # rel tag
    echo $REL_TAG exists in local repo ${PWD}, removing it
    $debug git tag -d $REL_TAG

    prev_rel=$(prev_rel)

    # local
    if tag_local_exists ${prev_rel}; then

        echo "Previous release exists in the local repo: ${prev_rel}"
        $debug git checkout ${prev_rel}

        echo $CYCLE_TAG exists in local repo, update it
        $debug git tag  -f $CYCLE_TAG
        $debug git push -f $REL $CYCLE_TAG
    else
        echo "Previous release does not exist, removing tag $CYCLE_TAG}"
        $debug git tag -d $CYCLE_TAG
        $debug git push --delete $REL $CYCLE_TAG
    fi

    # remote
    if tag_remote_exists $REL_TAG $REL; then
        echo $REL_TAG exists in $REL, removing it
        $debug git push --delete $REL $REL_TAG
    else
        exit_error $REL_TAG does not exist in $REL
    fi

    # set the sync status
    $debug set_sync.pl --repo "${PWD}" --verbose --tag_impl PROD

    # remove tar from release area
    cat $REPOS_CONF | grep release_area | sed 's/ //g' > /tmp/rel_areas
    . /tmp/rel_areas

    OS=''
    if [[ ${APPLICATION} == *-NT* ]]; then
        OS=NT
    fi
    OS_NAME=${OS:-UNIX}

    tar="${release_area}/BAT_${CYCLE}/${APPLICATION}/${CYCLE}-${APPLICATION}-${OS_NAME}-Release_${RELEASE}.tar.gz"

    if [[ -f "${tar}" ]]; then
        echo Tar exists in primary release area, removing it
        $debug rm -rf $tar
    else
        echo $tar does not exist, nothing to remove
    fi

    exit_error $REL_TAG does not exist

done

echo
echo "$(basename $0): All done"
