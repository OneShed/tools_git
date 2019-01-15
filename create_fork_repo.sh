#!/bin/bash

# Usage: $0 [<repo_name>]
# Creates a new repo in rel org and forks it to dev
#
# Example: $0 cs.ddr_ddl description topic cs-scm-luxembourg,cs-scm-frankfurt wg399,hm410
#
# $github_token must be exported (e.g. put it to .bashrc)

set -e
set -u 

GIT_TOOLS_DIR=/local/git/scm/tools_git
GIT_TOOLS=/local/git/scm/GIT/svn2git
GITHUB_URL=https://github.deutsche-boerse.de

# mandatory
repo="${1}"
description=${2}
topic=${3}
teams=${4} #teamname,admin,,teamname2,write
collaborators=${5}
team_id_rel=103 # SCM Luxembourg

token="${SCMLUXADM_TOKEN}"

# create repo in rel, add '-v' for verbose output
"${GIT_TOOLS}/createGitHubRepo.py" --token "${token}" --url $GITHUB_URL -o rel "${repo}" -t ${team_id_rel} --description $description 

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

echo Add topic on the repos
$GIT_TOOLS_DIR/addTopic.bash -r "${repo}" -t ${topic} -o dev -u scmluxadm -k $SCMLUXADM_TOKEN
$GIT_TOOLS_DIR/addTopic.bash -r "${repo}" -t ${topic} -o rel -u scmluxadm -k $SCMLUXADM_TOKEN

# add Team in dev
teams_array=(${teams//,,/ })
for t in ${teams_array[@]}; do
    $GIT_TOOLS/addTeam.py "${repo}" dev $t 
done

# add Collaborator
collaborators_array=(${collaborators//,/ })
for t in ${collaborators_array[@]}; do
    $GIT_TOOLS/addCollaborator.py "${repo}" dev $t 
done





exit_error() # {{{
{
	echo "$(basename $0): ${1:-"Unknown Error"}" 1>&2
	exit 1
} # }}}

echo "$(basename $0): All done"
