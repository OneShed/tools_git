#!/usr/bin/bash

# print out a repo summary
# usage: $0 $reponame $org

set -e
set -u

repo=$1
org=$2
GIT_TOOLS=/local/git/scm/GIT/svn2git

echo name:$repo

# list the descripton of the repo
d=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X GET $GITHUB/api/v3/repos/$org/$repo | grep description | head -1 | sed 's/\"description\"://g' | sed 's/\"//g' | sed 's/,//g'  |  sed 's/^[ \t]*//;s/[ \t]*$//')

echo description:$d

# topics
topics=$(curl -L -s -u scmluxadm:$SCMLUXADM_TOKEN -X GET -H "Accept: application/vnd.github.mercy-preview+json" -H "Content-Type: application/json" $GITHUB/api/v3/repos/dev/$repo/topics | egrep -v "{|}|\[|\]" | sed 's/\"//g' | sed 's/,//g' | sed 's/\s//g')

top=''
for t in ${topics[@]}; do
    top+="$t,"
done

echo topics:$top

# teams and permissions
$GIT_TOOLS/repoTeams.py $org $repo

# list collaborators
# github3 doesn't implement this yet, use curl instead
function get_collaborators {
collab_names=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X  \
    GET $GITHUB/api/v3/repos/$org/$repo/collaborators?affiliation=$affiliation\
    | egrep '"login":' | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')

admin=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X  \
    GET $GITHUB/api/v3/repos/$org/$repo/collaborators?affiliation=$affiliation\
    | egrep '"admin":' | sed 's/\"admin\": //' | sed 's/\,//' )

push=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X  \
    GET $GITHUB/api/v3/repos/$org/$repo/collaborators?affiliation=$affiliation\
    | egrep '"push":'  | sed 's/\"push\": //' | sed 's/\,//')

pull=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X  \
    GET $GITHUB/api/v3/repos/$org/$repo/collaborators?affiliation=$affiliation\
    | egrep '"pull":'  | sed 's/\"pull\": //' | sed 's/\,//')

admin_array=($admin)
push_array=($push)
pull_array=($pull)

## parse the array of <perm>, <true/false>
counter=0
perms=''
perms=''
for name in ${collab_names[@]}; do

    admin=$(eval echo "\${admin_array[\$counter]}")
    if [[ $admin == 'true' ]]; then
        perm='admin'
        perms+=$name,$perm,,
        counter=$((counter+1))
        continue
    fi

    push=$(eval echo "\${push_array[\$counter]}")
    if [[ $push == 'true' ]]; then
        perm='write'
        perms+=$name,$perm,,
        counter=$((counter+1))
        continue
    fi

    pull=$(eval echo "\${pull_array[\$counter]}")
    if [[ $pull == 'true' ]]; then
        perm='read'
        counter=$((counter+1))
        perms+=$name,$perm,,
        continue
    fi
done

echo collaborators_$affiliation:$perms
}

# all
export affiliation='direct'
get_collaborators

# outside
export affiliation='outside'
get_collaborators



