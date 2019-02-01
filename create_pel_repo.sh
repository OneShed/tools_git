#!/bin/bash

# Usage: $0 [<repo_name>]
# Creates a new PEL repo in rel org and forks it to dev
#
# Example: $0 AM-UNIX 
#
# $SCMLUXADM_TOKEN must be exported (e.g. put it to .bashrc)
# Create the local git repo
# Create remotes (both rel and for to dev)
# Add empty PEL.xml and README.md
# Push master to remotes


set -e
set -u 
#set -x

GIT_TOOLS_DIR=/local/git/scm/tools_git
GIT_TOOLS=/local/git/scm/GIT/svn2git
PEL_DIR=/local/git/scm/pckg_list
GITHUB=https://github.deutsche-boerse.de

# mandatory
repo="${1}"
reponame="cs.$(echo ${repo,,})-pel"

# curl -H "Authorization: token $SCMLUXADM_TOKEN" $GITHUB/api/v3/orgs/rel/teams
# "name": "SCM Luxembourg",
#    "id": 103,
teamId_rel=103
#
## bash->use '+' for spaces 
description="EPR+PEL+(Package+Element+List)+for+application+$repo"

echo Create repo in rel
# create repo in rel, add '-v' for verbose output
"${GIT_TOOLS}/createGitHubRepo.py" --token "${SCMLUXADM_TOKEN}" --url $GITHUB -o rel -t ${teamId_rel} "${reponame}" --description $description

echo Setup the local repo
cd $PEL_DIR
mkdir -p $repo
cd $repo
git init
git remote add origin $GITHUB/dev/$reponame
git remote add scm_repo $GITHUB/rel/$reponame

. ${GIT_TOOLS_DIR}/add_readme.sh $repo

cp $GIT_TOOLS_DIR/pel.xml .
mv pel.xml ${repo}.xml
git add .
git commit -a -m 'Initial commit'

git push scm_repo master

echo Make the fork
"${GIT_TOOLS}/forkGitHubRepo.py" --sourceOrg rel --targetOrg dev "${reponame}" --token "${SCMLUXADM_TOKEN}"
$GIT_TOOLS/addCollaborator.py $reponame dev scmluxadm
git push origin master

echo Add topic 'cfm' on the repos
$GIT_TOOLS_DIR/addTopic.bash -r "${reponame}" -t cfm -o dev -u scmluxadm -k $SCMLUXADM_TOKEN
$GIT_TOOLS_DIR/addTopic.bash -r "${reponame}" -t cfm -o rel -u scmluxadm -k $SCMLUXADM_TOKEN

echo Add webhook
$GIT_TOOLS_DIR/add_hook.sh $reponame

echo Lock master
$GIT_TOOLS_DIR/lock_branch.sh $reponame master 

exit_error() # {{{
{
	echo "$(basename $0): ${1:-"Unknown Error"}" 1>&2
	exit 1
} # }}}

echo "$(basename $0): All done"
