#!/bin/bash

# Usage: $0 [<repo_name>]
# Creates a new build_script repo in rel org and forks it to dev
#
# Example: $0 AM-UNIX 
#
# $SCMLUXADM_TOKEN must be exported (e.g. put it to .bashrc)
# Create the local git repo
# Create remotes (both rel and for to dev)
# Add empty script.sh and README.md
# Push master to remotes


set -e
set -u 
#set -x

GIT_TOOLS_DIR=/local/git/scm/tools_git
GIT_TOOLS=/local/git/scm/GIT/svn2git
BS_DIR=/local/git/scm/build_scripts
GITHUB=https://github.deutsche-boerse.de

# mandatory
repo="${1}"
reponame="cs.$(echo ${repo,,})-build"

# curl -H "Authorization: token $SCMLUXADM_TOKEN" $GITHUB/api/v3/orgs/rel/teams
# "name": "SCM Luxembourg",
#    "id": 103,
teamId_rel=103

# bash->use '+' for spaces 
description="EPR+build+script+for+application+$repo"

echo Create repo in rel
# create repo in rel, add '-v' for verbose output
"${GIT_TOOLS}/createGitHubRepo.py" --token "${SCMLUXADM_TOKEN}" --url $GITHUB -o rel -t ${teamId_rel} "${reponame}" --description $description

echo Setup the local repo
cd $BS_DIR
mkdir -p $repo
cd $repo
git init

p=$(git remote -v | grep origin || true)

if [[ -n $p ]]; then
    git remote remove origin
fi
git remote add origin $GITHUB/dev/$reponame
git remote add scm_repo $GITHUB/rel/$reponame

. ${GIT_TOOLS_DIR}/add_readme.sh $repo

cp $GIT_TOOLS_DIR/script.sh .
mv script.sh ${repo,,}.sh
chmod 755 ${repo,,}.sh
git add .
git commit -a -m 'Add README.md'

git push scm_repo master

echo Make the fork
"${GIT_TOOLS}/forkGitHubRepo.py" --sourceOrg rel --targetOrg dev "${reponame}" --token "${SCMLUXADM_TOKEN}"
$GIT_TOOLS/addCollaborator.py $reponame dev scmluxadm
git push origin master

echo Add topic 'cfm' on the repos
$GIT_TOOLS_DIR/addTopic.bash -r "${reponame}" -t cfm -o dev -u scmluxadm -k $SCMLUXADM_TOKEN
$GIT_TOOLS_DIR/addTopic.bash -r "${reponame}" -t cfm -o rel -u scmluxadm -k $SCMLUXADM_TOKEN

echo Add the webhook
$GIT_TOOLS_DIR/add_hook.sh $reponame

exit_error() # {{{
{
	echo "$(basename $0): ${1:-"Unknown Error"}" 1>&2
	exit 1
} # }}}

echo "$(basename $0): All done"
