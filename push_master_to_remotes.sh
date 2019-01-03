#!/bin/bash

set -e
set -u
# set -x

# in all repos, push master to origin

cd /local/git/scm/pckg_list
URL=https://github.deutsche-boerse.de

for repo in $(ls); do
    if [[ $repo != 'PckgElmnt.dtd' && ! ${repo} =~ ".sh" ]]; then
        echo $repo;
        cd $repo;

        git push origin master
        git push scm_repo master

        cd ..;
    fi;
done
echo All done
