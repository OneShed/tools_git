#!/bin/bash

# Create (move) master to tag $1 and push it to rel repo for all repos in $PWD
# e.g $0 CBLR1640
# Skip if PREPROD exists.

set -e
set -u

TAG=$1
repos_dir=${PWD}
TAG_PREPROD="${TAG}_PREPROD"
REL=https://github.deutsche-boerse.de/rel

preprods=()
# Return 1 if PREPROD exists -> no move of master should be done.
has_preprod() {

    # check for PREPROD tags
    TAGS=$(git tag | sed 's/\n//' )
    if [[ "${TAGS[@]}" =~ "${TAG_PREPROD}" ]]; then
        rev_preprod=$(git rev-parse $TAG_PREPROD)
        rev_master=$(git rev-parse master)

        # master is on PREPROD
        if [[ "${rev_preprod}" == "${rev_master}" ]]; then
            echo 1
        fi
    fi
}

# ignore the unrelated cycle directories 
repos=$(find -maxdepth 1 -type d | egrep '[a-z]')
tag_repos=$(find $TAG -maxdepth 1 -type d | egrep -v ^${TAG}$)
repos=( "${repos[*]}" "${tag_repos[*]}" )

for dir in ${repos[*]}; do 

    if [[ -e "${dir}/.git" ]] ; then

        repo=$dir
        cd $repo
        tags=$(git tag | sed 's/\n//' )

        for tag in ${tags[*]}; do
            if [[ ${tag} == ${TAG} ]]; then
                echo Repo: $dir
                echo "--------------"
                if [[ "${TAG}" == *PREPROD || $(has_preprod) != '1' ]]; then
                    git branch -f master ${TAG}
                    echo 'Pushing master to scm_repo'
                    repo=$(echo $repo | sed -e 's/^\.\///' -e 's/^.*\///')
                    git push -f $REL/$repo master

                    # Set sync status against master
                    set_sync.pl --repo "${PWD}" --verbose --tag_impl "${TAG}"

                    break
                else
                    echo "$(basename $0): $TAG_PREPROD exists => nothing done."
                    # log it 
                    preprods+=($PWD) 
                fi
            fi

        done

        cd $repos_dir
    fi
done

set +u
if [[ ! -z ${preprods[@]} ]]; then
    echo
    echo "Repos skipped due to PREPROD:"
    echo "${preprods[@]}"
fi

echo
echo "$(basename $0): All done"
