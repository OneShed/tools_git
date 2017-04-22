#!/bin/bash

# Push data from ClearCase VOB to $URL (Github repo) 
# Usage: $0 [<vob>] [<repo_name>]
# Copy from VOB to git repo
#
# Example: $0 /vobs/RDF cs.rdf
# You must be in ClearCase view to run ths script

set -e
set -u 

CT=/opt/rational/clearcase/bin/cleartool
GIT=/usr/bin/git

# Mandatory args
vob="${1}"
repo="${2}"

# Organization hardcoded here
URL="https://github.deutsche-boerse.de/rel/${repo}"

function exit_error() # {{{
{
    echo "$(basename $0): ${1:-"Unknown Error"}" 1>&2
    exit 1
} # }}}

# Check that current view context
PWV=$($CT pwv -s)
if [ -z "${PWV##*NONE*}" ]; then
    exit_error "You must be in the view to run this script"
fi

if [ -d "${vob}" ]; then
    cd ${vob};
else
    exit_error "$vob not found"
fi

# Create repo and push to origin 
$GIT init
echo 'lost+found' > .gitignore
$GIT add . 
$GIT commit -a -m"Initial commit by ${USER}"

remote=$($GIT remote)
if [[ ! "${remote}" =~ "origin" ]]; then
    echo "Adding remote $URL"
    $GIT remote add origin $URL
fi

$GIT push -f origin master

echo "All done"
echo
