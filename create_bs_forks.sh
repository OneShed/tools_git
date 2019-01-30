#!/bin/bash

set -e
set -u

cd /local/git/scm/pckg_list

for repo in $(ls); do
    if [[ $repo != 'PckgElmnt.dtd' && ! ${repo} =~ ".sh" ]]; then
       /local/git/scm/tools_git/create_pel_repo.sh $repo
    fi;
done
