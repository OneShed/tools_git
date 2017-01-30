#!/bin/bash

# Usage: $0 [<repo_name>]
# Creates a new repo in rel org and forks it to dev
#
# Example: $0 cs.ddr_ddl
#
# $github_token must be exported (e.g. put it to .bashrc)

set -e
set -u 

GIT_TOOLS_DIR=$(dirname $0)
GIT_TOOLS=$(dirname $GIT_TOOLS_DIR)/GIT/svn2git
URL=https://github.deutsche-boerse.de

# mandatory
repo="${1}"
token="${github_token}"

# create repo in rel, add '-v' for verbose output
"${GIT_TOOLS}/createGitHubRepo.py" --token "${token}" --url $URL -o rel "${repo}"

# put a README.md inside
git clone https://github.deutsche-boerse.de/rel/"${repo}".git
cd "${repo}"
echo "# $repo" >> README.md
git add README.md
git commit -m "first commit"
git push -u origin master

cd ..
rm -rf "${repo}"

# fork to dev, add '-v' for verbose output
"${GIT_TOOLS}/forkGitHubRepo.py" --sourceOrg rel --targetOrg dev "${repo}" --token "${token}"

exit_error() # {{{
{
	echo "$(basename $0): ${1:-"Unknown Error"}" 1>&2
	exit 1
} # }}}

echo "$(basename $0): All done"
