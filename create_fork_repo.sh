#!/bin/bash

# Usage: $0 [<repo_name>]
# Creates a new repo in rel org and forks it to dev
#
# Example: $0 cs.ddr_ddl description topic cs-cfm-community,admin,,cs-scm-frankfurt,write wg399,hm410
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
topics=${3,,}
# optional
teams=${4:-} #teamname,admin,,teamname2,write
collaborators_dev=${5:-}
# TODO collaborators_rel=${6:-}
team_id_rel=103 # SCM Luxembourg

token="${SCMLUXADM_TOKEN}"

# test repo exists in rel 
out=$(curl -i -H "Authorization: token $SCMLUXADM_TOKEN" -X GET $GITHUB/api/v3/repos/rel/$repo | egrep '404 Not Found') || true

# if not, create it
if [[ -n $out ]]; then

    # create repo in rel and add the default CFM team, add '-v' for verbose output
    "${GIT_TOOLS}/createGitHubRepo.py" --private --token "${token}" --url $GITHUB_URL -o rel "${repo}" -t ${team_id_rel} --description $description 
    
    cd /tmp
    # put a README.md inside
    git clone https://github.deutsche-boerse.de/rel/"${repo}".git
    cd "${repo}"
    echo "# $repo" > README.md
    git add README.md
    git commit -m "first commit"
    git push -u origin master
    
    cd ..
    rm -rf "${repo}"
else
    echo Repo already exists in rel, skipping
fi

# test repo exists in dev
out=$(curl -i -H "Authorization: token $SCMLUXADM_TOKEN" -X GET $GITHUB/api/v3/repos/dev/$repo | egrep '404 Not Found') || true

# if not, fork it
if [[ -n $out ]]; then
    # fork to dev, add '-v' for verbose output
    "${GIT_TOOLS}/forkGitHubRepo.py" --sourceOrg rel --targetOrg dev "${repo}" --token "${token}"
else
    echo Repo already exists in dev, skipping
fi

echo Add topics on repos
topics_array=(${topics//,/ })
for t in ${topics_array[@]}; do
    $GIT_TOOLS_DIR/addTopic.bash -r "${repo}" -t ${t} -o dev -u scmluxadm -k $SCMLUXADM_TOKEN
    $GIT_TOOLS_DIR/addTopic.bash -r "${repo}" -t ${t} -o rel -u scmluxadm -k $SCMLUXADM_TOKEN
done

## optional params
# add Teams in dev
if [[ -n $teams ]]; then
    teams_array=(${teams//,,/ })
    for t in ${teams_array[@]}; do
        echo Add repo dev/$repo to team $t
        $GIT_TOOLS/addTeam.py "${repo}" dev $t 
    done
else
    echo No teams will be set
fi

# add Collaborators in dev
if [[ -n $collaborators_dev ]]; then
    collaborators_dev_array=(${collaborators_dev//,/ })
    for t in ${collaborators_dev_array[@]}; do
        echo Add collaborator $t on repo dev/$repo
        $GIT_TOOLS/addCollaborator.py "${repo}" dev $t 
    done
else
    echo No collaborators will be set
fi

## add Collaborators in rel
#collaborators_rel_array=(${collaborators_rel//,/ })
#for t in ${collaborators_rel_array[@]}; do
#    $GIT_TOOLS/addCollaborator.py "${repo}" dev $t 
#done

exit_error() # {{{
{
	echo "$(basename $0): ${1:-"Unknown Error"}" 1>&2
	exit 1
} # }}}

echo "$(basename $0): All done"
