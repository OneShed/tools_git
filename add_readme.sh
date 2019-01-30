#!/bin/bash

set -e
set -u

echo "# $reponame" > README.md
echo "Updates to be done on branch ***devl_\<cycle\>*** e.g ***devl_cblr...***" >> README.md
echo "## wiki" >> README.md
echo https://github.deutsche-boerse.de/dev/cs.cfm_documents/blob/master/Update_build_or_pel.md  >> README.md
echo "## contact:" >> README.md
echo "CFM@clearstream.com" >> README.md

echo $(basename $0): All done
