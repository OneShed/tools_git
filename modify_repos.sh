#!/bin/bash

set -e
set -u

cd /local/git/scm/build_scripts
#cd /local/git/scm/pckg_list

for repo in $(ls); do
    if [[ $repo != 'PckgElmnt.dtd' && ! ${repo} =~ ".sh" ]]; then
#        /local/git/scm/tools_git/lock_branch.sh "cs.$(echo ${repo,,})-build"  master
    fi;
done
