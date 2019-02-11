#!/bin/bash

set -e
set -u
# set -x

# in all repos, push master to origin

echo Processing build_scripts directory 
cd /local/git/scm/build_scripts
URL=https://github.deutsche-boerse.de

for repo in $(ls | egrep -v OBSOLETE); do
    if [[ $repo != 'PckgElmnt.dtd' && ! ${repo} =~ ".sh" ]]; then
        echo $repo;
        cd $repo;

        git push origin master
        git push scm_repo master

        cd ..;
    fi;
done

echo
echo Processing PEL directory

cd /local/git/scm/pckg_list
for repo in $(ls | egrep -v OBSOLETE); do
    if [[ $repo != 'PckgElmnt.dtd' && ! ${repo} =~ ".sh" ]]; then
        echo $repo;
        cd $repo;

        git push origin master
        git push scm_repo master

        cd ..;
    fi;
done

echo $(basename $0): All done
