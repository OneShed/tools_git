#!/bin/bash

set -e
set -u
set -x

cd /local/git/scm/pckg_list
URL=https://github.deutsche-boerse.de

for repo in $(ls); do
    if [[ $repo != 'PckgElmnt.dtd' && ! ${repo} =~ ".sh" ]]; then
        echo $repo;
        cd $repo;
        reponame="cs.$(echo ${repo,,})-pel"

        git remote remove origin || true
        git remote remove scm_repo || true

        git remote add origin $URL/dev/$reponame
        git remote add scm_repo $URL/rel/$reponame

        cd ..;
    fi;
done
