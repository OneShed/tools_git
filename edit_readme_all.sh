#!/bin/bash

set -e
set -u

cd /local/git/scm/pckg_list

for repo in $(ls); do
    if [[ $repo != 'PckgElmnt.dtd' && ! ${repo} =~ ".sh" ]]; then
        cd $repo;
        repolow=cs.${repo,,}-pel
        git checkout master
        echo "# $repolow" > README.md
        echo "Updates to be done on branch ***devl_\<cycle\>*** e.g ***devl_cblr...***" >> README.md
        echo "## wiki" >> README.md
        echo https://github.deutsche-boerse.de/dev/cs.cfm_documents/blob/master/Update_build_or_pel.md  >> README.md
        echo "## contact:" >> README.md
        echo "CFM@clearstream.com" >> README.md
        git add README.md
        git commit -m "Edit README.md"
        git push origin master
        git push scm_repo master
        cd ..;
    fi;
done
